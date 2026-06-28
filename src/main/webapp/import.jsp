<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% if(session.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; } %>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>导入学生</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:"微软雅黑",sans-serif;background:#e8ecf1}
.nav{background:#fff;padding:12px 24px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 1px 4px rgba(0,0,0,0.1)}
.nav a{margin-left:16px;color:#4a90d9;text-decoration:none;font-size:14px}
.nav b{color:#333}
.main{max-width:800px;margin:20px auto;padding:0 16px}
.card{background:#fff;padding:20px;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);margin-bottom:16px}
h3{margin-bottom:12px}
.btn{padding:8px 16px;border:none;border-radius:4px;font-size:14px;cursor:pointer}
.btn-p{background:#4a90d9;color:#fff}
.btn-o{background:#fff;color:#4a90d9;border:1px solid #4a90d9}
.btn-g{background:#27ae60;color:#fff}
input[type=text],input[type=file]{padding:8px;border:1px solid #ddd;border-radius:4px;font-size:13px}
table{width:100%;border-collapse:collapse;font-size:13px;margin-top:8px}
th,td{padding:6px 8px;border-bottom:1px solid #eee;text-align:center}
th{background:#f5f6fa;color:#666;font-size:12px}
.msg{padding:10px;border-radius:4px;font-size:14px;margin-top:8px;display:none}
.msg.s{background:#d4edda;color:#155724;display:block}
.msg.e{background:#f8d7da;color:#721c24;display:block}
.msg.w{background:#fff3cd;color:#856404;display:block}
.tabs{display:flex;gap:0;margin-bottom:16px}
.tab{padding:8px 20px;border:1px solid #ddd;background:#f5f6fa;cursor:pointer;font-size:14px}
.tab.on{background:#4a90d9;color:#fff;border-color:#4a90d9}
.zone{border:2px dashed #ddd;padding:30px;text-align:center;border-radius:4px;cursor:pointer;margin:12px 0}
.zone:hover{border-color:#4a90d9;background:#f0f6ff}
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
<div class="card">
<div class="tabs">
<div class="tab on" onclick="switchTab(0)">文件导入</div>
<div class="tab" onclick="switchTab(1)">手动录入</div>
</div>

<div id="tab0">
<div class="zone" onclick="document.getElementById('fileInput').click()" id="zone">
<p>点击选择文件 或将文件拖拽到此处</p>
<p style="color:#999;font-size:12px">支持 .xlsx .xls .csv .txt</p>
<input type="file" id="fileInput" accept=".xlsx,.xls,.csv,.txt" style="display:none" onchange="showFile()">
</div>
<p id="fname" style="font-size:13px;color:#999"></p>
<button class="btn btn-p" id="upBtn" disabled onclick="upload()">开始导入</button>
<div id="msg0" class="msg"></div>
</div>

<div id="tab1" style="display:none">
<table><thead><tr><th>学号</th><th>姓名</th><th>性别</th><th>班级</th><th>操作</th></tr></thead>
<tbody id="mtbody">
<tr><td><input type="text" id="s0" style="width:100px"></td><td><input type="text" id="n0" style="width:80px"></td><td><select id="g0" style="padding:6px 4px;font-size:13px"><option value="">--</option><option value="男">男</option><option value="女">女</option></select></td><td><input type="text" id="c0" style="width:110px"></td><td><button class="btn btn-o" style="font-size:12px" onclick="delRow(this)">删除</button></td></tr>
</tbody></table>
<button class="btn btn-o" style="margin-top:8px" onclick="addRow()">+ 添加</button>
<button class="btn btn-p" style="margin-top:8px" onclick="submitManual()">提交</button>
<div id="msg1" class="msg"></div>
</div>
</div>

<div class="card">
<h3>导入说明</h3>
<p style="font-size:13px;color:#666;line-height:1.8">
每行格式：<b>学号,姓名,性别,班级</b>（4列）或 <b>学号,姓名,班级</b>（3列兼容）<br>
Excel 第一行如果是标题会自动跳过。CSV/TXT 用逗号、Tab 或分号分隔。<br>
重复学号会被自动跳过，导入结果会提示重复数量。
</p>
</div>
</div>
<div class="footer">课堂点名系统</div>

<script>
var file=null,rowCount=1;
function switchTab(n){
    document.querySelectorAll(".tab")[0].className="tab"+(n==0?" on":"");
    document.querySelectorAll(".tab")[1].className="tab"+(n==1?" on":"");
    document.getElementById("tab0").style.display=n==0?"":"none";
    document.getElementById("tab1").style.display=n==1?"":"none";
}
// 文件
var zone=document.getElementById("zone");
zone.addEventListener("dragover",function(e){e.preventDefault();zone.style.borderColor="#4a90d9"});
zone.addEventListener("dragleave",function(){zone.style.borderColor="#ddd"});
zone.addEventListener("drop",function(e){e.preventDefault();zone.style.borderColor="#ddd";
    document.getElementById("fileInput").files=e.dataTransfer.files;showFile()});
function showFile(){file=document.getElementById("fileInput").files[0];
    document.getElementById("fname").textContent=file?file.name:"";document.getElementById("upBtn").disabled=!file}
function upload(){
    if(!file)return;var fd=new FormData();fd.append("file",file);
    document.getElementById("upBtn").disabled=true;
    fetch("import",{method:"POST",body:fd}).then(function(r){return r.json()}).then(function(d){
        document.getElementById("upBtn").disabled=false; var m=document.getElementById("msg0");
        if(d.error){m.className="msg e";m.textContent=d.error}
        else if(d.dup>0){m.className="msg w";m.textContent="成功 "+d.success+" 条, 失败 "+d.fail+" 条, 已跳过重复学号 "+d.dup+" 条"}
        else{m.className="msg s";m.textContent="成功 "+d.success+" 条, 失败 "+d.fail+" 条"}
    });
}
// 手动 - 使用 insertRow 避免清空已有输入
function addRow(){
    var t=document.getElementById("mtbody"), tr=t.insertRow(), idx=rowCount++;
    tr.innerHTML='<td><input type="text" id="s'+idx+'" style="width:100px"></td>'
        +'<td><input type="text" id="n'+idx+'" style="width:80px"></td>'
        +'<td><select id="g'+idx+'" style="padding:6px 4px;font-size:13px"><option value="">--</option><option value="男">男</option><option value="女">女</option></select></td>'
        +'<td><input type="text" id="c'+idx+'" style="width:110px"></td>'
        +'<td><button class="btn btn-o" style="font-size:12px" onclick="delRow(this)">删除</button></td>';
}
function delRow(b){var r=b.closest("tr");if(document.querySelectorAll("#mtbody tr").length>1)r.remove();else{r.querySelectorAll("input").forEach(function(i){i.value=""})}}
function submitManual(){
    var list=[], rows=document.querySelectorAll("#mtbody tr"), seen={}, dup=[];
    rows.forEach(function(r){
        var is=r.querySelectorAll("input"), sel=r.querySelector("select");
        var sid=is[0].value.trim(), name=is[1].value.trim(), gender=sel?sel.value:"", cls=is[2].value.trim();
        if(sid && name){
            if(seen[sid]){ dup.push(sid); }
            else{ seen[sid]=true; list.push({studentId:sid, name:name, gender:gender, className:cls}); }
        }
    });
    if(list.length===0){document.getElementById("msg1").className="msg e";document.getElementById("msg1").textContent="请填写数据";return}
    if(dup.length>0 && !confirm("以下学号在本次录入中重复，将被跳过:\n"+dup.join("\n")+"\n\n是否继续提交？"))return;
    var fd=new FormData();fd.append("type","batch");fd.append("data",JSON.stringify(list));
    fetch("import",{method:"POST",body:fd}).then(function(r){return r.json()}).then(function(d){
        var m=document.getElementById("msg1");
        if(d.error){m.className="msg e";m.textContent=d.error}
        else if(d.dup>0){m.className="msg w";m.textContent="成功 "+d.success+" 条, 失败 "+d.fail+" 条, 已跳过重复学号 "+d.dup+" 条"}
        else{m.className="msg s";m.textContent="成功 "+d.success+" 条, 失败 "+d.fail+" 条"}
    });
}
</script>
</body></html>
