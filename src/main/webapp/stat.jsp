<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.attendance.model.Student" %>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; }
    List<Student> students = (List<Student>) request.getAttribute("students");
    Integer totalCalls = (Integer) request.getAttribute("totalCalls");
    Integer totalCorrect = (Integer) request.getAttribute("totalCorrect");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");
    if(students==null) students=new java.util.ArrayList<>();
    if(totalCalls==null) totalCalls=0; if(totalCorrect==null) totalCorrect=0; if(totalRecords==null) totalRecords=0;
    double rate = totalRecords>0 ? (double)totalCorrect/totalRecords*100 : 0;
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>统计报表</title>
<script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:"微软雅黑",sans-serif;background:#e8ecf1}
.nav{background:#fff;padding:12px 24px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 1px 4px rgba(0,0,0,0.1)}
.nav a{margin-left:16px;color:#4a90d9;text-decoration:none;font-size:14px}
.nav b{color:#333}
.main{max-width:1100px;margin:20px auto;padding:0 16px}
.card{background:#fff;padding:20px;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);margin-bottom:16px}
.summary{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:16px}
.sum{background:#f5f6fa;padding:16px;text-align:center;border-radius:4px}
.sum b{display:block;font-size:28px;color:#4a90d9}
.sum span{font-size:13px;color:#999}
table{width:100%;border-collapse:collapse;font-size:13px}
th,td{padding:8px;border-bottom:1px solid #eee;text-align:center}
th{background:#f5f6fa;color:#666;font-size:12px}
.green{color:#27ae60;font-weight:bold}
.red{color:#e74c3c;font-weight:bold}
.chart{height:380px}
.btn{padding:8px 16px;border:1px solid #4a90d9;border-radius:4px;color:#4a90d9;background:#fff;cursor:pointer;font-size:13px;margin-bottom:12px}
.btn:hover{background:#f0f6ff}
.footer{text-align:center;padding:20px;color:#999;font-size:12px}
</style></head>
<body>
<div class="nav">
<b>课堂点名系统</b>
<div>
<a href="call.jsp">点名</a>
<a href="stat">统计</a>
<a href="import.jsp">导入</a>
<a href="login.jsp" style="color:#e74c3c">退出</a>
</div>
</div>

<div class="main">
<div class="summary">
<div class="sum"><b><%=students.size()%></b><span>学生总数</span></div>
<div class="sum"><b><%=totalRecords%></b><span>点名次数</span></div>
<div class="sum"><b><%=totalCorrect%></b><span>答对次数</span></div>
<div class="sum"><b><%=String.format("%.1f%%",rate)%></b><span>正确率</span></div>
</div>

<button class="btn" onclick="window.open('stat?format=csv')">导出 CSV</button>

<div class="card"><div class="chart" id="chart"></div></div>

<div class="card">
<h3>学生明细（按正确率排序）</h3>
<div style="max-height:450px;overflow:auto">
<table><thead><tr><th>排名</th><th>学号</th><th>姓名</th><th>班级</th><th>点名</th><th>答对</th><th>正确率</th></tr></thead>
<tbody>
<% List<Student> sorted=new java.util.ArrayList<>(students);
   sorted.sort((a,b)->Double.compare(b.getCorrectRate(),a.getCorrectRate()));
   int rank=1;
   for(Student s:sorted){ double r=s.getCorrectRate(); %>
<tr><td><%=rank++%></td><td><%=s.getStudentId()%></td><td><%=s.getName()%></td><td><%=s.getClassName()%></td>
<td><%=s.getTotalCalled()%></td><td><%=s.getTotalCorrect()%></td>
<td class="<%=r>=60?"green":(s.getTotalCalled()>0?"red":"")%>"><%=String.format("%.1f%%",r)%></td></tr>
<% } %>
</tbody></table></div></div>
</div>
<div class="footer">课堂点名系统</div>

<script>
var n=[],c=[],r=[];
<% for(Student s:students){ %>n.push('<%=s.getName()%>');c.push(<%=s.getTotalCalled()%>);r.push(<%=String.format("%.1f",s.getCorrectRate())%>);<% } %>
if(n.length){var ch=echarts.init(document.getElementById("chart"));
ch.setOption({tooltip:{trigger:"axis"},grid:{left:50,right:50,top:20,bottom:30},
xAxis:{type:"category",data:n,axisLabel:{rotate:n.length>8?30:0,fontSize:11}},
yAxis:[{type:"value",name:"次数"},{type:"value",name:"正确率%"}],
series:[{name:"点名次数",type:"bar",data:c,color:"#4a90d9"},{name:"正确率%",type:"line",yAxisIndex:1,data:r,color:"#27ae60"}]})}
</script>
</body></html>
