<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>课堂点名系统 - 登录</title>
    <style>
        :root {
            --primary: #4f46e5;
            --primary-light: #6366f1;
            --danger: #ef4444;
            --bg: #f1f5f9;
            --card: #ffffff;
            --text: #1e293b;
            --text-muted: #64748b;
            --border: #e2e8f0;
            --radius: 12px;
            --shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: "Segoe UI", "微软雅黑", sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center;
        }
        .login-wrapper { width: 100%; max-width: 420px; padding: 20px; }
        .login-card {
            background: var(--card); border-radius: 16px; padding: 40px 32px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
        }
        .login-header { text-align: center; margin-bottom: 32px; }
        .login-header .icon { font-size: 48px; margin-bottom: 12px; }
        .login-header h2 { font-size: 24px; color: var(--text); font-weight: 700; }
        .login-header p { color: var(--text-muted); font-size: 14px; margin-top: 6px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: var(--text-muted); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }
        .form-group input {
            width: 100%; padding: 12px 16px; border: 1px solid var(--border);
            border-radius: 8px; font-size: 15px; transition: all 0.2s;
            background: #f8fafc;
        }
        .form-group input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(79,70,229,0.1); background: #fff; }
        .btn-login {
            width: 100%; padding: 12px; background: var(--primary); color: #fff;
            border: none; border-radius: 8px; font-size: 16px; font-weight: 600;
            cursor: pointer; transition: all 0.2s; margin-top: 8px;
        }
        .btn-login:hover { background: var(--primary-light); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(79,70,229,0.3); }
        .error-msg {
            background: #fee2e2; color: #991b1b; padding: 10px 14px;
            border-radius: 8px; font-size: 13px; margin-bottom: 16px; text-align: center;
        }
        .login-footer { text-align: center; margin-top: 20px; font-size: 12px; color: var(--text-muted); }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <div class="login-card">
            <div class="login-header">
                <div class="icon">&#127979;</div>
                <h2>课堂点名系统</h2>
                <p>教师登录</p>
            </div>

            <%-- 显示错误信息（兼容 error 和 errorMsg 两个属性名） --%>
            <%
                String error = (String) request.getAttribute("error");
                if (error == null) error = (String) request.getAttribute("errorMsg");
                if (error != null) {
            %>
            <div class="error-msg"><%= error %></div>
            <% } %>

            <form action="loginCheck" method="post">
                <div class="form-group">
                    <label>用户名</label>
                    <input type="text" name="username" placeholder="请输入用户名" required autofocus>
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" name="password" placeholder="请输入密码" required>
                </div>
                <button type="submit" class="btn-login">登 录</button>
            </form>
            <div class="login-footer">默认账号：admin / 123</div>
        </div>
    </div>
</body>
</html>
