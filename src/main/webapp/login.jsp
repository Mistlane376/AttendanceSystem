<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>课堂点名系统 - 登录</title>
    <style>
        body { font-family: "微软雅黑"; background: #f0f2f5; }
        .login-box {
            width: 300px; margin: 100px auto; padding: 20px;
            background: white; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        input { width: 100%; padding: 8px; margin: 8px 0; box-sizing: border-box; }
        button { width: 100%; padding: 8px; background: #007bff; color: white; border: none; cursor: pointer; }
        .error { color: red; }
    </style>
</head>
<body>
<div class="login-box">
    <h3>课堂点名系统</h3>
    <form action="loginCheck" method="post">
        <input type="text" name="username" placeholder="用户名" required><br>
        <input type="password" name="password" placeholder="密码" required><br>
        <button type="submit">登录</button>
        <% if(request.getAttribute("error") != null) { %>
        <p class="error"><%= request.getAttribute("error") %></p>
        <% } %>
    </form>
    <p style="font-size:12px; color:gray;">默认教师账号: admin / 123</p>
</div>
</body>
</html>