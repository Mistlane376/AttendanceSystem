<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.attendance.model.Student" %>
<%
    if(session.getAttribute("user") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<html>
<head>
    <title>点名界面</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { font-family: "微软雅黑"; background: #e9ecef; text-align: center; padding-top: 50px; }
        .call-card {
            background: white; width: 500px; margin: auto; padding: 30px;
            border-radius: 20px; box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .student-name { font-size: 48px; font-weight: bold; margin: 20px 0; color: #007bff; }
        button { font-size: 20px; padding: 10px 20px; margin: 10px; border: none; border-radius: 8px; cursor: pointer; }
        #callBtn { background: #28a745; color: white; }
        #correctBtn { background: #17a2b8; color: white; }
        #wrongBtn { background: #dc3545; color: white; }
        .disabled-btn { opacity: 0.6; pointer-events: none; }
        table { width: 80%; margin: 30px auto; border-collapse: collapse; background: white; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: center; }
        th { background: #007bff; color: white; }
    </style>
</head>
<body>
<div class="call-card">
    <h2>📢 课堂点名系统</h2>
    <div class="student-name" id="studentName">——</div>
    <button id="callBtn">🎲 开始点名</button>
    <button id="correctBtn" disabled>✔️ 答对</button>
    <button id="wrongBtn" disabled>❌ 答错</button>
</div>

<h3>📊 学生点名统计</h3>
<table id="statTable">
    <thead>
    <tr><th>学号</th><th>姓名</th><th>班级</th><th>点名次数</th><th>答对次数</th><th>正确率</th></tr>
    </thead>
    <tbody></tbody>
</table>

<script>
    let currentStudentId = null;

    function loadStudentList() {
        $.ajax({
            url: 'stat',
            type: 'GET',
            dataType: 'json',
            success: function(data) {
                let html = '';
                for(let i=0; i<data.length; i++) {
                    let s = data[i];
                    html += `<tr>
                        <td>${s.studentId}</td>
                        <td>${s.name}</td>
                        <td>${s.className}</td>
                        <td>${s.totalCalled}</td>
                        <td>${s.totalCorrect}</td>
                        <td>${(s.correctRate).toFixed(1)}%</td>
                    </tr>`;
                }
                $('#statTable tbody').html(html);
            }
        });
    }

    function callStudent() {
        $.ajax({
            url: 'call?action=getStudent',
            type: 'GET',
            success: function(student) {
                if(student && student.studentId) {
                    $('#studentName').text(student.name);
                    currentStudentId = student.studentId;
                    $('#callBtn').prop('disabled', true).addClass('disabled-btn');
                    $('#correctBtn').prop('disabled', false).removeClass('disabled-btn');
                    $('#wrongBtn').prop('disabled', false).removeClass('disabled-btn');
                } else {
                    alert('暂无学生数据，请先导入学生');
                }
            }
        });
    }

    function recordResult(isCorrect) {
        if(!currentStudentId) return;
        $.ajax({
            url: 'call?action=record&studentId=' + currentStudentId + '&isCorrect=' + isCorrect,
            type: 'GET',
            success: function(res) {
                if(res === 'success') {
                    alert(isCorrect ? '回答正确！' : '回答错误');
                    // 重置界面
                    $('#studentName').text('——');
                    currentStudentId = null;
                    $('#callBtn').prop('disabled', false).removeClass('disabled-btn');
                    $('#correctBtn').prop('disabled', true).addClass('disabled-btn');
                    $('#wrongBtn').prop('disabled', true).addClass('disabled-btn');
                    loadStudentList(); // 刷新表格
                } else {
                    alert('记录失败');
                }
            }
        });
    }

    $(function() {
        loadStudentList();
        $('#callBtn').click(callStudent);
        $('#correctBtn').click(function() { recordResult(true); });
        $('#wrongBtn').click(function() { recordResult(false); });
        // 每10秒自动刷新列表
        setInterval(loadStudentList, 10000);
    });
</script>
</body>
</html>