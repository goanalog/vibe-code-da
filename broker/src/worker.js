export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return new Response(null, { headers: corsHeaders() });
    const u = new URL(request.url);
    if (u.pathname !== "/sign") return json({ error: "Not found" }, 404);
    if (request.method !== "POST") return json({ error: "Use POST" }, 405);

    const accessKey = env.COS_ACCESS_KEY_ID;
    const secretKey = env.COS_SECRET_ACCESS_KEY;
    const region    = env.COS_REGION || "us-south";
    const endpoint  = `s3.${region}.cloud-object-storage.appdomain.cloud`;
    if (!accessKey || !secretKey) return json({ error: "Broker not configured" }, 500);

    let body; try { body = await request.json(); } catch { body = {}; }
    const key = (body?.key || "app.html").trim();
    const expires = clampInt(body?.expires, 60, 600) || 300;
    const bucket = String(body?.bucket || "").trim();

    if (key !== "app.html") return json({ error: "Only app.html is permitted" }, 403);
    if (!/^[a-z0-9][a-z0-9.-]+$/.test(bucket) || !bucket.startsWith("vibe-bucket-")) return json({ error: "Invalid bucket" }, 400);

    const method = "PUT", service = "s3", host = endpoint;
    const amzDate = nowAmzDate(), dateStamp = amzDate.substring(0,8);
    const credentialScope = `${dateStamp}/${region}/${service}/aws4_request`;
    const algorithm = "AWS4-HMAC-SHA256", signedHeaders = "host";
    const canonicalUri = `/${bucket}/${encodeURIComponent(key)}`;
    const q = new URLSearchParams({
      "X-Amz-Algorithm": algorithm,
      "X-Amz-Credential": `${accessKey}/${credentialScope}`,
      "X-Amz-Date": amzDate,
      "X-Amz-Expires": String(expires),
      "X-Amz-SignedHeaders": signedHeaders
    });
    const payloadHash = "UNSIGNED-PAYLOAD";
    const canonicalRequest = [method, canonicalUri, q.toString(), `host:${host}\n`, signedHeaders, payloadHash].join("\n");
    const stringToSign = [algorithm, amzDate, credentialScope, await sha256Hex(canonicalRequest)].join("\n");
    const signingKey = await getSigningKey(secretKey, dateStamp, region, service);
    const signature = await hmacHex(signingKey, stringToSign);
    const urlSigned = `https://${host}${canonicalUri}?${q.toString()}&X-Amz-Signature=${signature}`;
    return json({ url: urlSigned }, 200, { "Access-Control-Allow-Origin": "*" });
  }
};
function corsHeaders(){ return {"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"POST, OPTIONS","Access-Control-Allow-Headers":"Content-Type"}; }
function json(obj, status=200, extra={}){ return new Response(JSON.stringify(obj), { status, headers:{ "content-type":"application/json", ...corsHeaders(), ...extra } }); }
function clampInt(v,min,max){ const n=Number(v); if(!Number.isFinite(n)) return undefined; return Math.max(min, Math.min(max, Math.floor(n))); }
function nowAmzDate(d=new Date()){ const p=n=>String(n).padStart(2,"0"); return `${d.getUTCFullYear()}${p(d.getUTCMonth()+1)}${p(d.getUTCDate())}T${p(d.getUTCHours())}${p(d.getUTCMinutes())}${p(d.getUTCSeconds())}Z`; }
async function sha256Hex(str){ const data=new TextEncoder().encode(str); const hash=await crypto.subtle.digest("SHA-256", data); return hex(hash); }
async function hmac(key,msg,algo="SHA-256"){ const k=await crypto.subtle.importKey("raw", typeof key==="string"?new TextEncoder().encode(key):key,{name:"HMAC",hash:algo},false,["sign"]); const sig=await crypto.subtle.sign("HMAC", k, new TextEncoder().encode(msg)); return sig; }
async function hmacHex(key,msg){ const sig=await hmac(key,msg); return hex(sig); }
function hex(buf){ const v=new Uint8Array(buf); return [...v].map(b=>b.toString(16).padStart(2,"0")).join(""); }
async function getSigningKey(secret,date,region,service){ const kDate=await hmac("AWS4"+secret,date); const kRegion=await hmac(kDate,region); const kSvc=await hmac(kRegion,service); const kSig=await hmac(kSvc,"aws4_request"); return kSig; }
