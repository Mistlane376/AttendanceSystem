<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.attendance.model.Student, com.attendance.service.CallService" %>
<%
    if(session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    CallService callService = new CallService();
    List<Student> students = callService.getAllStudents();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>课堂点名 - 点名系统</title>
    <style>
        :root {
            --primary: #4f46e5;
            --primary-light: #6366f1;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --bg: #f1f5f9;
            --card: #ffffff;
            --text: #1e293b;
            --text-muted: #64748b;
            --border: #e2e8f0;
            --radius: 12px;
            --shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Segoe UI", "微软雅黑", sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; }

        .navbar {
            background: var(--card); border-bottom: 1px solid var(--border);
            padding: 0 24px; height: 60px; display: flex; align-items: center;
            justify-content: space-between; box-shadow: var(--shadow);
            position: sticky; top: 0; z-index: 100;
        }
        .navbar .logo { font-size: 20px; font-weight: 700; color: var(--primary); }
        .navbar nav { display: flex; gap: 4px; }
        .navbar nav a {
            padding: 8px 16px; border-radius: 8px; text-decoration: none;
            color: var(--text-muted); font-weight: 500; font-size: 14px; transition: all 0.2s;
        }
        .navbar nav a:hover, .navbar nav a.active { background: #eef2ff; color: var(--primary); }
        .navbar .user-info { font-size: 14px; color: var(--text-muted); display: flex; align-items: center; gap: 12px; }
        .navbar .btn-logout { padding: 6px 14px; background: var(--danger); color: #fff; border: none; border-radius: 6px; cursor: pointer; font-size: 13px; }

        .container { max-width: 1200px; margin: 24px auto; padding: 0 24px; display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        @media (max-width: 900px) { .container { grid-template-columns: 1fr; } }

        .card { background: var(--card); border-radius: var(--radius); padding: 24px; box-shadow: var(--shadow); border: 1px solid var(--border); }
        .card.call-card { text-align: center; }
        .card h3 { font-size: 18px; margin-bottom: 16px; }

        .student-display {
            background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
            border-radius: var(--radius); padding: 40px 20px; margin: 20px 0;
            min-height: 160px; display: flex; flex-direction: column;
            align-items: center; justify-content: center; transition: all 0.3s;
        }
        .student-name { font-size: 48px; font-weight: 700; color: var(--primary); }
        .student-id { font-size: 16px; color: var(--text-muted); margin-top: 8px; }
        .student-class { font-size: 14px; color: var(--text-muted); }
        .placeholder-text { font-size: 20px; color: #94a3b8; }

        .btn-group { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; margin-top: 12px; }
        .btn {
            padding: 12px 24px; border: none; border-radius: 8px; font-size: 16px;
            font-weight: 600; cursor: pointer; transition: all 0.2s; display: inline-flex;
            align-items: center; gap: 6px;
        }
        .btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .btn-call { background: var(--primary); color: #fff; font-size: 20px; padding: 14px 40px; }
        .btn-call:hover:not(:disabled) { background: var(--primary-light); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(79,70,229,0.3); }
        .btn-correct { background: var(--success); color: #fff; }
        .btn-correct:hover:not(:disabled) { opacity: 0.9; transform: translateY(-1px); }
        .btn-wrong { background: var(--danger); color: #fff; }
        .btn-wrong:hover:not(:disabled) { opacity: 0.9; transform: translateY(-1px); }

        .info-msg {
            margin-top: 16px; padding: 12px 16px; border-radius: 8px; font-size: 14px;
            display: none; text-align: center;
        }
        .info-msg.show { display: block; }
        .info-msg.info { background: #dbeafe; color: #1e40af; }
        .info-msg.success { background: #d1fae5; color: #065f46; }
        .info-msg.warning { background: #fef3c7; color: #92400e; }

        .stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 20px; }
        .stat-item {
            background: #f8fafc; border-radius: 8px; padding: 12px; text-align: center; border: 1px solid var(--border);
        }
        .stat-item .val { font-size: 24px; font-weight: 700; color: var(--primary); }
        .stat-item .lbl { font-size: 12px; color: var(--text-muted); margin-top: 4px; }

        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        th, td { padding: 10px 12px; border-bottom: 1px solid var(--border); text-align: center; }
        th { background: #f8fafc; font-weight: 600; color: var(--text-muted); font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover { background: #f8fafc; }
        .rate-high { color: var(--success); font-weight: 600; }
        .rate-low { color: var(--danger); font-weight: 600; }
        .table-wrapper { max-height: 500px; overflow-y: auto; }

        .empty-hint { text-align: center; padding: 48px; color: var(--text-muted); font-size: 16px; }
        .footer { text-align: center; padding: 24px; color: var(--text-muted); font-size: 13px; }
    </style>
</head>
<body>
    <div class="navbar">
        <div class="logo">课堂点名系统</div>
        <nav>
            <a href="call.jsp" class="active">点名</a>
            <a href="stat">统计</a>
            <a href="import.jsp">导入学生</a>
        </nav>
        <div class="user-info">
            <span><%= session.getAttribute("user") %></span>
            <button class="btn-logout" onclick="location.href='login.jsp'">退出</button>
        </div>
    </div>

    <div class="container">
        <!-- 左列：点名区域 -->
        <div>
            <div class="card call-card">
                <h3>课堂随机点名</h3>
                <div class="student-display" id="studentDisplay">
                    <div class="placeholder-text" id="placeholder">--- 点击下方按钮开始点名 ---</div>
                    <div class="student-name" id="studentName" style="display:none;"></div>
                    <div class="student-id" id="studentId" style="display:none;"></div>
                    <div class="student-class" id="studentClass" style="display:none;"></div>
                </div>
                <div class="btn-group">
                    <button class="btn btn-call" id="callBtn">随机点名</button>
                    <button class="btn btn-correct" id="correctBtn" disabled>答对了</button>
                    <button class="btn btn-wrong" id="wrongBtn" disabled>答错了</button>
                </div>
                <div id="infoMsg" class="info-msg"></div>
            </div>

            <div class="card" style="margin-top: 24px;">
                <h3>点名统计概览</h3>
                <div class="stats-row">
                    <div class="stat-item"><div class="val" id="statTotal"><%= students.size() %></div><div class="lbl">学生总数</div></div>
                    <%
                        int totalCalls = 0, totalCorrect = 0;
                        for (Student s : students) {
                            totalCalls += s.getTotalCalled();
                            totalCorrect += s.getTotalCorrect();
                        }
                        double rate = totalCalls > 0 ? (double) totalCorrect / totalCalls * 100 : 0;
                    %>
                    <div class="stat-item"><div class="val"><%= totalCalls %></div><div class="lbl">总点名次数</div></div>
                    <div class="stat-item"><div class="val"><%= totalCorrect %></div><div class="lbl">总答对数</div></div>
                    <div class="stat-item"><div class="val"><%= String.format("%.1f%%", rate) %></div><div class="lbl">总正确率</div></div>
                </div>
            </div>
        </div>

        <!-- 右列：学生列表 -->
        <div class="card">
            <h3>学生点名统计表</h3>
            <% if (students.isEmpty()) { %>
                <div class="empty-hint">
                    <p>暂无学生数据</p>
                    <p style="font-size:14px;margin-top:8px;">请先 <a href="import.jsp" style="color:var(--primary);">导入学生</a></p>
                </div>
            <% } else { %>
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr><th>学号</th><th>姓名</th><th>班级</th><th>点名</th><th>答对</th><th>正确率</th></tr>
                        </thead>
                        <tbody>
                            <% for(Student s : students) {
                                double r = s.getCorrectRate();
                                String cls = r >= 60 ? "rate-high" : (s.getTotalCalled() > 0 ? "rate-low" : "");
                            %>
                            <tr>
                                <td><%= s.getStudentId() %></td>
                                <td><%= s.getName() %></td>
                                <td><%= s.getClassName() %></td>
                                <td><%= s.getTotalCalled() %></td>
                                <td><%= s.getTotalCorrect() %></td>
                                <td class="<%= cls %>"><%= String.format("%.1f%%", r) %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>

    <div class="footer">课堂点名系统 &copy; 2026</div>

    <script>
        let currentStudentId = null;
        const callBtn = document.getElementById('callBtn');
        const correctBtn = document.getElementById('correctBtn');
        const wrongBtn = document.getElementById('wrongBtn');
        const placeholder = document.getElementById('placeholder');
        const studentNameEl = document.getElementById('studentName');
        const studentIdEl = document.getElementById('studentId');
        const studentClassEl = document.getElementById('studentClass');
        const infoMsg = document.getElementById('infoMsg');

        function showInfo(text, type) {
            infoMsg.textContent = text;
            infoMsg.className = 'info-msg show ' + type;
        }

        function hideInfo() { infoMsg.className = 'info-msg'; }

        function showStudent(name, id, cls) {
            placeholder.style.display = 'none';
            studentNameEl.style.display = 'block';
            studentIdEl.style.display = 'block';
            studentClassEl.style.display = 'block';
            studentNameEl.textContent = name;
            studentIdEl.textContent = '学号：' + id;
            studentClassEl.textContent = cls ? '班级：' + cls : '';
        }

        function resetDisplay() {
            placeholder.style.display = 'block';
            studentNameEl.style.display = 'none';
            studentIdEl.style.display = 'none';
            studentClassEl.style.display = 'none';
        }

        callBtn.onclick = function() {
            callBtn.disabled = true;
            showInfo('正在选择学生...', 'info');

            fetch('call?action=getStudent')
                .then(r => r.json())
                .then(data => {
                    if (data && data.studentId) {
                        currentStudentId = data.studentId;
                        showStudent(data.name, data.studentId, data.className);
                        correctBtn.disabled = false;
                        wrongBtn.disabled = false;
                        showInfo('点名：' + data.name + ' (' + data.studentId + ')，请判断是否答对', 'info');
                    } else {
                        resetDisplay();
                        callBtn.disabled = false;
                        showInfo('没有学生数据，请先导入学生', 'warning');
                    }
                })
                .catch(err => {
                    callBtn.disabled = false;
                    showInfo('点名失败，请检查网络连接', 'warning');
                });
        };

        function recordResult(isCorrect) {
            if (!currentStudentId) {
                showInfo('请先点击点名按钮', 'warning');
                return;
            }

            correctBtn.disabled = true;
            wrongBtn.disabled = true;

            fetch('call?action=record&studentId=' + encodeURIComponent(currentStudentId) + '&isCorrect=' + isCorrect)
                .then(r => r.text())
                .then(result => {
                    if (result === 'success') {
                        showInfo(isCorrect ? '记录成功：答对了！' : '记录成功：答错了', isCorrect ? 'success' : 'info');
                        resetDisplay();
                        currentStudentId = null;
                        callBtn.disabled = false;
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        correctBtn.disabled = false;
                        wrongBtn.disabled = false;
                        showInfo('记录失败（后端返回: ' + result + '），请重试', 'warning');
                    }
                })
                .catch(err => {
                    correctBtn.disabled = false;
                    wrongBtn.disabled = false;
                    showInfo('网络请求失败，请重试', 'warning');
                });
        }

        correctBtn.onclick = () => recordResult(true);
        wrongBtn.onclick = () => recordResult(false);
    </script>
</body>
</html>
