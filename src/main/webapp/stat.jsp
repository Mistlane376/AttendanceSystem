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
<html>
<head>
  <title>点名统计报表</title>
  <style>
    body { font-family: "微软雅黑"; background: #f0f2f5; padding: 20px; }
    .container { max-width: 1000px; margin: auto; background: white; border-radius: 8px; padding: 20px; }
    h2 { text-align: center; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: center; }
    th { background: #007bff; color: white; }
    .chart-container { width: 80%; margin: 30px auto; }
  </style>
  <!-- 引入 ECharts -->
  <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
</head>
<body>
<div class="container">
  <h2>点名统计报表</h2>
  <table>
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

  <div class="chart-container">
    <div id="calledChart" style="height: 400px;"></div>
  </div>
</div>

<script>
  // 准备图表数据
  let names = [];
  let calledCounts = [];
  let correctRates = [];
  <% for(Student s : students) { %>
  names.push("<%= s.getName() %>");
  calledCounts.push(<%= s.getTotalCalled() %>);
  correctRates.push(<%= s.getCorrectRate() %>);
  <% } %>

  var chartDom = document.getElementById('calledChart');
  var myChart = echarts.init(chartDom);
  var option = {
    title: { text: '学生点名次数与正确率' },
    tooltip: { trigger: 'axis' },
    legend: { data: ['点名次数', '正确率(%)'] },
    xAxis: { type: 'category', data: names, axisLabel: { rotate: 30 } },
    yAxis: [{ type: 'value', name: '点名次数' }, { type: 'value', name: '正确率(%)' }],
    series: [
      { name: '点名次数', type: 'bar', data: calledCounts },
      { name: '正确率(%)', type: 'line', yAxisIndex: 1, data: correctRates, smooth: true }
    ]
  };
  myChart.setOption(option);
</script>
</body>
</html>