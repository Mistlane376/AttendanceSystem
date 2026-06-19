<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.attendance.model.Student, com.attendance.service.CallService" %>
<%
    // 检查是否登录（如果不需要登录可以注释掉）
    if(session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    CallService callService = new CallService();
    List<Student> students = callService.getAllStudents();
%>
<html>
<head>
    <title>课堂点名系统 - 点名</title>
    <style>
        body { font-family: "微软雅黑"; background: #f0f2f5; text-align: center; margin: 0; padding: 20px; }
        .container { max-width: 1200px; margin: auto; background: white; border-radius: 8px; padding: 20px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .call-area { background: #e9ecef; border-radius: 8px; padding: 30px; margin-bottom: 30px; }
        .student-name { font-size: 48px; font-weight: bold; color: #007bff; margin: 20px 0; }
        button { font-size: 20px; padding: 10px 20px; margin: 10px; border: none; border-radius: 5px; cursor: pointer; }
        .btn-call { background: #28a745; color: white; }
        .btn-correct { background: #007bff; color: white; }
        .btn-wrong { background: #dc3545; color: white; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: center; }
        th { background: #007bff; color: white; }
        .info { margin-top: 20px; font-size: 14px; color: gray; }
    </style>
</head>
<body>
<div class="container">
    <h2>课堂点名系统</h2>
    <div class="call-area">
        <div class="student-name" id="studentName">--- 点击点名 ---</div>
        <div>
            <button class="btn-call" id="callBtn">🎲 开始点名</button>
            <button class="btn-correct" id="correctBtn" disabled>✓ 答对</button>
            <button class="btn-wrong" id="wrongBtn" disabled>✗ 答错</button>
        </div>
        <div class="info" id="infoMsg"></div>
    </div>

    <h3>学生点名统计表</h3>
    <table id="studentTable">
        <thead>
        <tr><th>学号</th><th>姓名</th><th>班级</th><th>点名次数</th><th>答对次数</th><th>正确率</th></tr>
        </thead>
        <tbody>
        <% for(Student s : students) { %>
        <tr>
            <td><%= s.getStudentId() %></td>
            <td><%= s.getName() %></td>
            <td><%= s.getClassName() %></td>
            <td><%= s.getTotalCalled() %></td>
            <td><%= s.getTotalCorrect() %></td>
            <td><%= String.format("%.1f%%", s.getCorrectRate()) %></td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<script>
    // 全局变量：当前点名的学生学号
    let currentStudentId = null;

    const callBtn = document.getElementById('callBtn');
    const correctBtn = document.getElementById('correctBtn');
    const wrongBtn = document.getElementById('wrongBtn');
    const studentNameSpan = document.getElementById('studentName');
    const infoMsg = document.getElementById('infoMsg');

    // 点名
    callBtn.onclick = function() {
        fetch('call?action=getStudent')
            .then(response => response.json())
            .then(data => {
                console.log("点名返回数据:", data);  // 调试：控制台查看返回的学生对象
                if(data && data.studentId) {
                    currentStudentId = data.studentId;   // 关键：保存学号
                    studentNameSpan.innerHTML = data.name;
                    correctBtn.disabled = false;
                    wrongBtn.disabled = false;
                    callBtn.disabled = true;
                    infoMsg.innerHTML = `点名：${data.name} (学号:${data.studentId})，请判断是否答对`;
                } else {
                    infoMsg.innerHTML = "没有学生数据，请先导入学生";
                }
            })
            .catch(err => {
                console.error("点名请求失败:", err);
                infoMsg.innerHTML = "点名失败，请检查后端";
            });
    };

    // 记录结果（答对/答错）
    function recordResult(isCorrect) {
        if(!currentStudentId) {
            infoMsg.innerHTML = "错误：没有当前点名学生，请先点名";
            console.error("recordResult: currentStudentId 为空");
            return;
        }
        console.log("发送记录请求: studentId=" + currentStudentId + ", isCorrect=" + isCorrect);
        fetch('call?action=record&studentId=' + encodeURIComponent(currentStudentId) + '&isCorrect=' + isCorrect)
            .then(response => response.text())
            .then(result => {
                console.log("记录结果返回:", result);
                if(result === "success") {
                    infoMsg.innerHTML = isCorrect ? "✓ 记录成功：答对了！" : "✗ 记录成功：答错了";
                    // 重置界面
                    currentStudentId = null;
                    studentNameSpan.innerHTML = "--- 点击点名 ---";
                    correctBtn.disabled = true;
                    wrongBtn.disabled = true;
                    callBtn.disabled = false;
                    // 刷新页面以更新表格
                    setTimeout(() => location.reload(), 800);
                } else {
                    infoMsg.innerHTML = "记录失败，请重试（后端返回：" + result + "）";
                }
            })
            .catch(err => {
                console.error("记录请求失败:", err);
                infoMsg.innerHTML = "记录请求发送失败，请检查网络";
            });
    }

    correctBtn.onclick = () => recordResult(true);
    wrongBtn.onclick = () => recordResult(false);
</script>
</body>
</html>