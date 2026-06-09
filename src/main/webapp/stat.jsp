<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.attendance.model.Student" %>
<%
  if(session.getAttribute("user") == null) {
    response.sendRedirect("index.jsp");
    return;
  }
  List<Student> students = (List<Student>) request.getAttribute("studentList");
%>
<html>
<head>
  <title>点名统计</title>
  <style>
    body { font-family: "微软雅黑"; padding: 20px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: center; }
    th { background: #007bff; color: white; }
    .back { margin-bottom: 20px; display: inline-block; }
  </style>
</head>
<body>
<a href="call.jsp" class="back">← 返回点名</a>
<h2>学生点名统计报表</h2>
<table>
  <thead>
  <tr><th>学号</th><th>姓名</th><th>班级</th><th>被点名次数</th><th>答对次数</th><th>正确率(%)</th></tr>
  </thead>
  <tbody>
  <% for(Student s : students) { %>
  <tr>
    <td><%= s.getStudentId() %></td>
    <td><%= s.getName() %></td>
    <td><%= s.getClassName() %></td>
    <td><%= s.getTotalCalled() %></td>
    <td><%= s.getTotalCorrect() %></td>
    <td><%= String.format("%.1f", s.getCorrectRate()) %>%</td>
  </tr>
  <% } %>
  </tbody>
</table>
</body>
</html>