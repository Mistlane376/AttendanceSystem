<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if(session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>导入学生 - 课堂点名系统</title>
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

        /* 导航栏 */
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
            color: var(--text-muted); font-weight: 500; font-size: 14px;
            transition: all 0.2s;
        }
        .navbar nav a:hover, .navbar nav a.active { background: #eef2ff; color: var(--primary); }
        .navbar .user-info { font-size: 14px; color: var(--text-muted); display: flex; align-items: center; gap: 12px; }
        .navbar .btn-logout { padding: 6px 14px; background: var(--danger); color: #fff; border: none; border-radius: 6px; cursor: pointer; font-size: 13px; }
        .navbar .btn-logout:hover { opacity: 0.9; }

        /* 主容器 */
        .container { max-width: 1000px; margin: 24px auto; padding: 0 24px; display: flex; flex-direction: column; gap: 24px; }
        .card { background: var(--card); border-radius: var(--radius); padding: 24px; box-shadow: var(--shadow); border: 1px solid var(--border); }
        .card h3 { font-size: 18px; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }

        /* 标签切换 */
        .tabs { display: flex; gap: 0; margin-bottom: -1px; }
        .tab-btn {
            padding: 10px 20px; border: 1px solid var(--border); background: #f8fafc;
            cursor: pointer; font-size: 14px; font-weight: 500; transition: all 0.2s;
            color: var(--text-muted);
        }
        .tab-btn:first-child { border-radius: 8px 0 0 0; }
        .tab-btn:last-child { border-radius: 0 8px 0 0; }
        .tab-btn.active { background: var(--card); color: var(--primary); border-bottom-color: var(--card); }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* 上传区域 */
        .upload-zone {
            border: 2px dashed var(--border); border-radius: var(--radius); padding: 48px;
            text-align: center; cursor: pointer; transition: all 0.2s;
        }
        .upload-zone:hover, .upload-zone.dragover { border-color: var(--primary); background: #eef2ff; }
        .upload-zone .icon { font-size: 48px; margin-bottom: 12px; }
        .upload-zone p { color: var(--text-muted); font-size: 14px; margin: 4px 0; }
        .upload-zone input[type=file] { display: none; }
        .file-hint { font-size: 12px; color: var(--text-muted); margin-top: 8px; }

        /* 表格 */
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px 12px; border-bottom: 1px solid var(--border); text-align: left; font-size: 14px; }
        th { background: #f8fafc; font-weight: 600; color: var(--text-muted); font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover { background: #f8fafc; }

        /* 按钮 */
        .btn {
            padding: 10px 20px; border: none; border-radius: 8px; font-size: 14px;
            font-weight: 500; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-primary { background: var(--primary); color: #fff; }
        .btn-primary:hover { background: var(--primary-light); }
        .btn-success { background: var(--success); color: #fff; }
        .btn-success:hover { opacity: 0.9; }
        .btn-outline { background: #fff; color: var(--primary); border: 1px solid var(--primary); }
        .btn-outline:hover { background: #eef2ff; }
        .btn-sm { padding: 6px 12px; font-size: 12px; border-radius: 6px; }
        .btn-danger { background: var(--danger); color: #fff; }

        /* 消息框 */
        .msg { padding: 12px 16px; border-radius: 8px; font-size: 14px; margin-top: 12px; display: none; }
        .msg.success { background: #d1fae5; color: #065f46; display: block; }
        .msg.error { background: #fee2e2; color: #991b1b; display: block; }
        .msg.warning { background: #fef3c7; color: #92400e; display: block; }

        /* 输入框 */
        input[type=text] {
            width: 100%; padding: 8px 12px; border: 1px solid var(--border); border-radius: 6px;
            font-size: 14px; transition: border-color 0.2s;
        }
        input[type=text]:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(79,70,229,0.1); }

        .btn-row { display: flex; gap: 8px; margin-top: 16px; }
        .preview-count { font-size: 14px; color: var(--text-muted); margin: 8px 0; }
        .badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .badge-success { background: #d1fae5; color: #065f46; }
        .badge-danger { background: #fee2e2; color: #991b1b; }

        /* 加载动画 */
        .spinner { display: none; width: 20px; height: 20px; border: 2px solid #e2e8f0; border-top-color: var(--primary); border-radius: 50%; animation: spin 0.6s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* 页脚 */
        .footer { text-align: center; padding: 24px; color: var(--text-muted); font-size: 13px; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <div class="navbar">
        <div class="logo">课堂点名系统</div>
        <nav>
            <a href="call.jsp">点名</a>
            <a href="stat">统计</a>
            <a href="import.jsp" class="active">导入学生</a>
        </nav>
        <div class="user-info">
            <span><%= session.getAttribute("user") %></span>
            <button class="btn-logout" onclick="location.href='login.jsp'">退出</button>
        </div>
    </div>

    <div class="container">
        <!-- 标签切换 -->
        <div class="card">
            <div class="tabs">
                <button class="tab-btn active" onclick="switchTab('file')">文件导入</button>
                <button class="tab-btn" onclick="switchTab('manual')">手动录入</button>
            </div>

            <!-- 文件上传 -->
            <div id="tab-file" class="tab-content active" style="padding-top: 24px;">
                <div class="upload-zone" id="uploadZone" onclick="document.getElementById('fileInput').click()">
                    <div class="icon">&#128194;</div>
                    <p><strong>点击选择文件</strong> 或将文件拖拽到此处</p>
                    <p class="file-hint">支持 .xlsx / .xls / .csv / .txt，每行格式：学号,姓名,班级</p>
                    <input type="file" id="fileInput" accept=".xlsx,.xls,.csv,.txt" onchange="handleFileSelect(event)">
                </div>
                <div id="fileName" style="margin-top: 12px; font-size: 14px; color: var(--text-muted);"></div>
                <div class="btn-row">
                    <button class="btn btn-primary" id="btnUpload" disabled onclick="uploadFile()">
                        <span class="spinner" id="uploadSpinner"></span> 开始导入
                    </button>
                </div>
                <div id="uploadMsg"></div>
            </div>

            <!-- 手动录入 -->
            <div id="tab-manual" class="tab-content" style="padding-top: 24px;">
                <div style="overflow-x: auto;">
                    <table id="manualTable">
                        <thead>
                            <tr><th>学号</th><th>姓名</th><th>班级</th><th>操作</th></tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><input type="text" id="sid_0" placeholder="如：2021001"></td>
                                <td><input type="text" id="name_0" placeholder="如：张三"></td>
                                <td><input type="text" id="cls_0" placeholder="如：软件工程1班"></td>
                                <td><button class="btn btn-danger btn-sm" onclick="delRow(this)">删除</button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="btn-row">
                    <button class="btn btn-outline" onclick="addRow()">+ 添加一行</button>
                    <button class="btn btn-primary" onclick="submitManual()">
                        <span class="spinner" id="manualSpinner"></span> 提交导入
                    </button>
                </div>
                <div id="manualMsg"></div>
            </div>
        </div>

        <!-- 导入说明 -->
        <div class="card">
            <h3>导入说明</h3>
            <table>
                <thead><tr><th>格式</th><th>说明</th><th>示例</th></tr></thead>
                <tbody>
                    <tr><td>Excel (.xlsx/.xls)</td><td>第一行为表头（可选），列为：学号 | 姓名 | 班级</td><td>2021001 | 张三 | 软件工程1班</td></tr>
                    <tr><td>CSV / TXT</td><td>逗号、制表符或分号分隔，每行一个学生</td><td>2021001,张三,软件工程1班</td></tr>
                    <tr><td>手动录入</td><td>在上方表格中逐行填写，支持动态增删</td><td>---</td></tr>
                </tbody>
            </table>
        </div>
    </div>
    <div class="footer">课堂点名系统 &copy; 2026</div>

    <script>
        let selectedFile = null;
        let rowCounter = 1;

        function switchTab(name) {
            document.querySelectorAll('.tab-btn').forEach((b, i) => {
                b.classList.toggle('active', (name === 'file' && i === 0) || (name === 'manual' && i === 1));
            });
            document.getElementById('tab-file').classList.toggle('active', name === 'file');
            document.getElementById('tab-manual').classList.toggle('active', name === 'manual');
            document.getElementById('uploadMsg').innerHTML = '';
            document.getElementById('manualMsg').innerHTML = '';
        }

        // ========== 文件上传 ==========
        const uploadZone = document.getElementById('uploadZone');
        uploadZone.addEventListener('dragover', e => { e.preventDefault(); uploadZone.classList.add('dragover'); });
        uploadZone.addEventListener('dragleave', () => uploadZone.classList.remove('dragover'));
        uploadZone.addEventListener('drop', e => {
            e.preventDefault();
            uploadZone.classList.remove('dragover');
            if (e.dataTransfer.files.length > 0) {
                document.getElementById('fileInput').files = e.dataTransfer.files;
                handleFileSelect({ target: { files: e.dataTransfer.files } });
            }
        });

        function handleFileSelect(e) {
            selectedFile = e.target.files[0];
            document.getElementById('fileName').innerHTML = selectedFile ? '已选择: ' + selectedFile.name : '';
            document.getElementById('btnUpload').disabled = !selectedFile;
            document.getElementById('uploadMsg').innerHTML = '';
        }

        function uploadFile() {
            if (!selectedFile) return;
            const formData = new FormData();
            formData.append('file', selectedFile);

            document.getElementById('uploadSpinner').style.display = 'inline-block';
            document.getElementById('btnUpload').disabled = true;

            fetch('import', { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    document.getElementById('uploadSpinner').style.display = 'none';
                    document.getElementById('btnUpload').disabled = false;
                    const msg = document.getElementById('uploadMsg');
                    if (data.error) {
                        msg.innerHTML = '<div class="msg error">' + data.error + '</div>';
                    } else {
                        msg.innerHTML = '<div class="msg success">导入完成！成功 <span class="badge badge-success">'
                            + data.success + '</span> 条，失败 <span class="badge badge-danger">'
                            + data.fail + '</span> 条（共解析 ' + data.total + ' 条）</div>';
                        if (data.errors && data.errors.length > 0) {
                            msg.innerHTML += '<div class="msg warning">' + data.errors.slice(0,5).join('<br>') + '</div>';
                        }
                    }
                })
                .catch(err => {
                    document.getElementById('uploadSpinner').style.display = 'none';
                    document.getElementById('btnUpload').disabled = false;
                    document.getElementById('uploadMsg').innerHTML = '<div class="msg error">上传失败: ' + err.message + '</div>';
                });
        }

        // ========== 手动录入 ==========
        function addRow() {
            const tbody = document.querySelector('#manualTable tbody');
            const tr = document.createElement('tr');
            tr.innerHTML = '<td><input type="text" id="sid_' + rowCounter + '" placeholder="如：2021001"></td>'
                + '<td><input type="text" id="name_' + rowCounter + '" placeholder="如：张三"></td>'
                + '<td><input type="text" id="cls_' + rowCounter + '" placeholder="如：软件工程1班"></td>'
                + '<td><button class="btn btn-danger btn-sm" onclick="delRow(this)">删除</button></td>';
            tbody.appendChild(tr);
            rowCounter++;
        }

        function delRow(btn) {
            const tbody = document.querySelector('#manualTable tbody');
            if (tbody.rows.length <= 1) {
                // 清空最后一行
                const row = tbody.rows[0];
                row.querySelectorAll('input').forEach(i => i.value = '');
                return;
            }
            btn.closest('tr').remove();
        }

        function submitManual() {
            const rows = document.querySelectorAll('#manualTable tbody tr');
            const students = [];
            rows.forEach(row => {
                const inputs = row.querySelectorAll('input');
                const sid = inputs[0].value.trim();
                const name = inputs[1].value.trim();
                const cls = inputs[2].value.trim();
                if (sid && name) students.push({ studentId: sid, name: name, className: cls });
            });

            if (students.length === 0) {
                document.getElementById('manualMsg').innerHTML = '<div class="msg warning">请至少填写一行学生信息</div>';
                return;
            }

            document.getElementById('manualSpinner').style.display = 'inline-block';
            const formData = new FormData();
            formData.append('type', 'batch');
            formData.append('data', JSON.stringify(students));

            fetch('import', { method: 'POST', body: formData })
                .then(r => r.json())
                .then(data => {
                    document.getElementById('manualSpinner').style.display = 'none';
                    const msg = document.getElementById('manualMsg');
                    if (data.error) {
                        msg.innerHTML = '<div class="msg error">' + data.error + '</div>';
                    } else {
                        msg.innerHTML = '<div class="msg success">导入完成！成功 <span class="badge badge-success">'
                            + data.success + '</span> 条，失败 <span class="badge badge-danger">'
                            + data.fail + '</span> 条（共提交 ' + data.total + ' 条）</div>';
                    }
                })
                .catch(err => {
                    document.getElementById('manualSpinner').style.display = 'none';
                    document.getElementById('manualMsg').innerHTML = '<div class="msg error">提交失败: ' + err.message + '</div>';
                });
        }
    </script>
</body>
</html>
