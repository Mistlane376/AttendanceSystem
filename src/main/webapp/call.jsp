<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.attendance.model.Student, com.attendance.service.CallService" %>
<%
    if(session.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; }
    CallService cs = new CallService();
    List<Student> students = cs.getAllStudents();
    int tCalls=0, tCorrect=0;
    for(Student s:students){ tCalls+=s.getTotalCalled(); tCorrect+=s.getTotalCorrect(); }
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>课堂点名</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:"微软雅黑",sans-serif;background:#e8ecf1}
.nav{background:#fff;padding:12px 24px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 1px 4px rgba(0,0,0,0.1)}
.nav a{margin-left:16px;color:#4a90d9;text-decoration:none;font-size:14px}.nav a:hover{text-decoration:underline}
.nav b{color:#333}
.main{max-width:1100px;margin:20px auto;padding:0 16px;display:grid;grid-template-columns:1fr 1fr;gap:20px}
@media(max-width:800px){.main{grid-template-columns:1fr}}
.card{background:#fff;padding:20px;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08)}
.call-area{text-align:center}
.name-display{font-size:42px;font-weight:bold;color:#4a90d9;padding:30px 0;min-height:120px;display:flex;align-items:center;justify-content:center;flex-direction:column}
.name-display .sub{font-size:16px;color:#999;font-weight:normal}
.btn{padding:10px 20px;border:none;border-radius:4px;font-size:16px;cursor:pointer;margin:4px}
.btn:disabled{opacity:.5;cursor:not-allowed}
.btn-call{background:#4a90d9;color:#fff;font-size:20px;padding:12px 36px}
.btn-ok{background:#27ae60;color:#fff}
.btn-no{background:#e74c3c;color:#fff}
.msg{margin-top:12px;padding:8px;border-radius:4px;font-size:14px;display:none}
.msg.s{background:#d4edda;color:#155724;display:block}
.msg.e{background:#f8d7da;color:#721c24;display:block}
table{width:100%;border-collapse:collapse;font-size:13px}
th,td{padding:8px;border-bottom:1px solid #eee;text-align:center}
th{background:#f5f6fa;color:#666;font-size:12px}
.btn-sm{padding:4px 10px;font-size:12px;margin:1px}
.green{color:#27ae60;font-weight:bold}
.red{color:#e74c3c;font-weight:bold}
.summary{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px}
.summary div{background:#f5f6fa;padding:8px;text-align:center;border-radius:4px;font-size:13px}
.summary b{display:block;font-size:20px;color:#4a90d9}
.toolbar{margin-bottom:12px}
.toolbar input{padding:6px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:160px}
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
<div>
<div class="card call-area">
<h3>随机点名</h3>
<div class="name-display" id="display"><span style="color:#ccc">点击下方按钮开始</span></div>
<button class="btn btn-call" id="callBtn">开始点名</button>
<button class="btn btn-ok" id="okBtn" disabled>答对了</button>
<button class="btn btn-no" id="noBtn" disabled>答错了</button>
<div id="msg" class="msg"></div>
<div class="summary">
<div><b><%=students.size()%></b>学生数</div>
<div><b><%=tCalls%></b>点名次数</div>
</div>
</div>
</div>

<div class="card">
<div class="toolbar">
<input type="text" id="search" placeholder="搜索学号/姓名..." oninput="filter()">
</div>
<div style="max-height:500px;overflow:auto">
<table><thead><tr><th>学号</th><th>姓名</th><th>班级</th><th>点名</th><th>答对</th><th>正确率</th><th>操作</th></tr></thead>
<tbody id="tbody">
<% for(Student s:students){ double r=s.getCorrectRate();
   String rc=r>=60?"green":(s.getTotalCalled()>0?"red":""); %>
<tr data-sid="<%=s.getStudentId()%>">
<td><%=s.getStudentId()%></td>
<td class="name-cell"><%=s.getName()%></td>
<td class="cls-cell"><%=s.getClassName()%></td>
<td><%=s.getTotalCalled()%></td>
<td><%=s.getTotalCorrect()%></td>
<td class="<%=rc%>"><%=String.format("%.1f%%",r)%></td>
<td>
<button class="btn btn-sm btn-ok" onclick="editRow(this)">编辑</button>
<button class="btn btn-sm btn-no" onclick="delStudent(this)">删除</button>
</td></tr>
<% } %>
</tbody></table></div>
<div id="tmsg" class="msg"></div>
</div>
</div>
<div class="footer">课堂点名系统</div>

<script>
var curSid=null,callBtn=document.getElementById("callBtn"),okBtn=document.getElementById("okBtn"),
    noBtn=document.getElementById("noBtn"),display=document.getElementById("display"),
    msg=document.getElementById("msg");

callBtn.onclick=function(){
    callBtn.disabled=true;msg.className="msg";msg.textContent="选择中...";
    fetch("call?action=getStudent").then(function(r){return r.json()}).then(function(d){
        if(d&&d.studentId){
            curSid=d.studentId;display.innerHTML=d.name+'<div class="sub">'+d.studentId+(d.className?" / "+d.className:"")+"</div>";
            okBtn.disabled=false;noBtn.disabled=false;msg.className="msg";
        }else{callBtn.disabled=false;display.innerHTML='<span style="color:#ccc">无学生数据</span>'}
    });
};
function record(ok){
    if(!curSid)return;okBtn.disabled=true;noBtn.disabled=true;
    fetch("call?action=record&studentId="+encodeURIComponent(curSid)+"&isCorrect="+ok)
    .then(function(r){return r.text()}).then(function(r){
        if(r==="success"){msg.className="msg s";msg.textContent=ok?"答对了!":"答错了";curSid=null;
            okBtn.disabled=true;noBtn.disabled=true;callBtn.disabled=false;
            display.innerHTML='<span style="color:#ccc">点击下方按钮开始</span>';setTimeout(function(){location.reload()},800);
        }else{okBtn.disabled=false;noBtn.disabled=false;msg.className="msg e";msg.textContent="记录失败"}
    });
}
okBtn.onclick=function(){record(true)};noBtn.onclick=function(){record(false)};

function filter(){
    var q=document.getElementById("search").value.toLowerCase(),rows=document.querySelectorAll("#tbody tr");
    rows.forEach(function(tr){tr.style.display=(!q||tr.textContent.toLowerCase().indexOf(q)>=0)?"":"none"});
}

function editRow(btn){
    var tr=btn.closest("tr"),sid=tr.getAttribute("data-sid");
    var name=tr.querySelector(".name-cell"),cls=tr.querySelector(".cls-cell");
    var oldName=name.textContent,oldCls=cls.textContent;
    name.innerHTML='<input type="text" id="eName" value="'+oldName+'" style="width:80px;padding:2px 4px;font-size:12px">';
    cls.innerHTML='<input type="text" id="eCls" value="'+oldCls+'" style="width:100px;padding:2px 4px;font-size:12px">';
    btn.textContent="保存";btn.className="btn btn-sm btn-call";btn.onclick=function(){saveEdit(tr,sid)};
}
function saveEdit(tr,sid){
    var fd=new FormData();fd.append("action","edit");fd.append("studentId",sid);
    fd.append("name",document.getElementById("eName").value);
    fd.append("className",document.getElementById("eCls").value);
    fetch("student",{method:"POST",body:fd}).then(function(r){return r.json()}).then(function(d){
        if(d.success)location.reload();else alert("保存失败");
    });
}
function delStudent(btn){
    var sid=btn.closest("tr").getAttribute("data-sid");
    if(!confirm("确定删除 "+sid+" ?"))return;
    var fd=new FormData();fd.append("action","delete");fd.append("studentId",sid);
    fetch("student",{method:"POST",body:fd}).then(function(r){return r.json()}).then(function(d){
        if(d.success){document.getElementById("tmsg").className="msg s";document.getElementById("tmsg").textContent="删除成功";setTimeout(function(){location.reload()},500);}
        else{document.getElementById("tmsg").className="msg e";document.getElementById("tmsg").textContent="删除失败"}
    });
}
</script>
</body></html>
