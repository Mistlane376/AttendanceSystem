<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>课堂点名系统</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:"微软雅黑",sans-serif;background:#e8ecf1;display:flex;justify-content:center;align-items:center;min-height:100vh}
.box{background:#fff;padding:40px 32px;border-radius:8px;box-shadow:0 2px 12px rgba(0,0,0,0.1);width:340px}
h2{text-align:center;margin-bottom:24px;color:#333}
input{width:100%;padding:10px 12px;margin:8px 0;border:1px solid #ddd;border-radius:4px;font-size:14px}
button{width:100%;padding:10px;background:#4a90d9;color:#fff;border:none;border-radius:4px;font-size:16px;cursor:pointer;margin-top:12px}
button:hover{background:#357abd}
.err{color:#e74c3c;font-size:13px;text-align:center;margin-bottom:8px}
.hint{text-align:center;color:#999;font-size:12px;margin-top:12px}
</style></head>
<body>
<div class="box">
<h2>课堂点名系统</h2>
<% String msg=(String)request.getAttribute("msg"); if(msg!=null){ %><div class="err" style="color:#27ae60"><%=msg%></div><% } %>
<% String e=(String)request.getAttribute("errorMsg"); if(e!=null){ %><div class="err"><%=e%></div><% } %>
<form action="loginCheck" method="post">
<input type="text" name="username" placeholder="用户名" required>
<input type="password" name="password" placeholder="密码" required>
<button type="submit">登录</button>
</form>
<div class="hint">默认: admin / 123 ｜ <a href="register.jsp" style="color:#4a90d9">注册</a></div>
</div>
</body></html>
