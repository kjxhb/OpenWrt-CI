const FileManager = {
    // ========== 初始化 ==========
    init: function() {
        // 关闭选择模式
        this.selectMode = false;
        // 初始化剪切板
        this.clipboard = { mode: null, sources: [], isdirs: [] };
        // 绑定按钮事件
        this.bindEvents();
        // 获取浏览器历史记录里保存的最后访问路径，没有就用根目录 /
        const lastPath = (history.state && history.state.path) || '/';
        // 把当前路径设置为上次访问的路径
        this.currentPath = lastPath;
        // 加载路径下的文件列表
        this.loadFileList(lastPath);
        // 渲染面包屑导航
        this.Breadcrumb(lastPath);
    },
    // ========== 绑定按钮事件 ==========
    bindEvents: function() {
        const self = this;
        $('#go-btn').click(function() {
            const path = $('#path-input').val().trim();
            if (path) self.loadFileList(path);
        });
        $('#select-mode-btn').click(function() { self.SelectMode(); });
        $('#mkdir-btn').click(function() { self.createFolder(); });
        $('#mkfile-btn').click(function() { self.createFile(); });
        $('#upload-file-btn').click(function() { self.uploadFile(false); });
        $('#upload-dir-btn').click(function() { self.uploadFile(true); });
        $('#copy-btn').click(function() { self.copySelected(); });
        $('#cut-btn').click(function() { self.cutSelected(); });
        $('#paste-btn').click(function() { self.paste(); });
        $('#batch-delete-btn').click(function() { self.deleteSelected(); });
        $('#terminal-btn').click(function() { self.Terminal(); });
        $('#pack-btn').click(function() { self.packSelected(); });
        $('#goback-btn').click(function() {
            const arr = self.currentPath.split('/').filter(Boolean);
            arr.pop();
            const up = '/' + arr.join('/');
            self.loadFileList(up);
        });

        $('#path-input').keydown(function(e) {
            if (e.keyCode === 13) {
                const path = $(this).val().trim();
                if (path) {
                    self.loadFileList(path);
                }
            }
        });
    },
    // ========== 选择模式 ==========
    SelectMode: function() {
        const self = this;
        self.selectMode = !self.selectMode;
        if (self.selectMode) {
            $('#select-mode-btn').text('取消选择');
            $('.fma-td-check').css('display', 'flex');
        } else {
            $('#select-mode-btn').text('选择');
            $('.fma-td-check').css('display', 'none');
            $('.fma-check-item').prop('checked', false);
        }
        self.updateBatchButtons();
    },

    exitSelectMode: function() {
        const self = this;
        self.selectMode = false;
        $('#select-mode-btn').text('选择');
        $('.fma-td-check').css('display', 'none');
        $('.fma-check-item').prop('checked', false);
        self.updateBatchButtons();
    },
    // ========== 更新批量按钮状态 ==========
    updateBatchButtons: function() {
        const hasChecked = $('.fma-check-item:checked').length > 0;
        $('#copy-btn, #cut-btn, #batch-delete-btn, #pack-btn').prop('disabled', !hasChecked);
        const hasClipboard = !!this.clipboard.mode;
        $('#paste-btn').prop('disabled', !hasClipboard);
    },
    // ========== 通用工具函数 ==========
    checkExists(path, name, isDir) {
        return new Promise((resolve, reject) => {
            $.post("/cgi-bin/luci/admin/nas/filemanager/check_exists", {
                path,
                name,
                isdir: isDir ? 1 : 0
            }, (res) => {
                if (res.exists !== 1) {
                    resolve(true);
                    return;
                }
                const type = isDir ? "文件夹" : "文件";
                const confirmMsg = `${name} ${type}已存在，是否覆盖？`;
                resolve(confirm(confirmMsg));
            }, "json").fail(() => reject("检查文件/文件夹存在性失败"));
        });
    },
    Progress: function(options) {
        const self = this;
        const defaultOpts = {
            total: 100,
            onProgress: () => {},
            onComplete: () => {},
            onCancel: () => {}
        };
        const opts = { ...defaultOpts, ...options };
        let isCanceled = false;

        // 显示进度条
        $('#fma-progress-container').show();
        $('#progress-fill').css('width', '0%');
        $('#progress-percent').text('0%');
        $('#progress-filename').text('处理中...');
        $('#progress-stats').text('');

        // 取消绑定
        $('#upload-cancel-btn').off('click').on('click', function() {
            isCanceled = true;
            $('#fma-progress-container').hide();
            opts.onCancel();
        });

        // 更新进度
        function updateProgress(loaded) {
            if (isCanceled) return;
            const percent = Math.min(Math.round((loaded / opts.total) * 100), 100);
            $('#progress-fill').css('width', percent + '%');
            $('#progress-percent').text(percent + '%');
            opts.onProgress(percent);
            if (percent >= 100) {
                setTimeout(() => {
                    $('#fma-progress-container').hide();
                    opts.onComplete();
                }, 500);
            }
        }

        return {
            update: updateProgress,
            isCanceled: () => isCanceled,
            finish: () => updateProgress(opts.total)
        };
    },
    // ========== 加载目录列表 ==========
    loadFileList: function(path) {
        const self = this;
        path = path.replace(/\/+/g, '/') || '/';
        self.currentPath = path;
        $('#path-input').val(path);
        self.Breadcrumb(path);
        $.get('/cgi-bin/luci/admin/nas/filemanager/list', { path }, function(res) {
            self.renderFileList(res.ec === 0 ? res.data : []);
        }).fail(() => self.renderFileList([]));
        $('#goback-btn').toggle(path !== '/');
        history.pushState({ path }, null, '?path=' + path);
    },
    renderFileList: function(list) {
        const self = this;
        const container = $('#file-list-container');
        const template = document.getElementById('file-item-template');
        container.empty();
        const parsedList = [];
        if (list) {
            list.forEach(line => {
                const m = line.match(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+([\S\s]+)/);
                if (!m) return;
                const isLink = 'zlx'.includes(m[1][0]);
                const name = isLink ? m[9].split(' -> ')[0] : m[9];
                const isDir = 'dz'.includes(m[1][0]);
                parsedList.push({ m, isLink, name, isDir });
            });
            parsedList.sort((a, b) => {
                const getSortWeight = (item) => {
                    if (item.isDir && !item.isLink) return 0;
                    if (item.isLink) return 1;
                    return 2;
                };
                const weightA = getSortWeight(a);
                const weightB = getSortWeight(b);
                if (weightA !== weightB) {
                    return weightA - weightB;
                }
                return a.name.localeCompare(b.name);
            });
        }
        parsedList.forEach((item, i) => {
            const { m, isLink, name, isDir } = item;
            const perm = m[1];
            const user = m[3];
            const size = m[5];
            const date = `${m[6]} ${m[7]} ${m[8]}`;
            const fullPath = self.currentPath + (self.currentPath.endsWith('/') ? '' : '/') + name;
            const $row = $(template.innerHTML).clone();
            const iconCls = isLink ? 'fma-icon-link' : (isDir ? 'fma-icon-folder' : 'fma-icon-file');
            $row.find('#check-item').data('path', fullPath).data('name', name).on('change', () => self.updateBatchButtons());
            $row.find('#file-name').addClass(iconCls).text(m[9]);
            $row.find('#info-user').text(user);
            $row.find('#info-date').text(date);
            $row.find('#info-size').text(size);
            $row.find('#info-perm').text(perm);
            $row.find('#rename-btn').click(e => { e.stopPropagation(); self.renameFile(fullPath, name); });
            $row.find('#delete-btn').click(e => { e.stopPropagation(); self.deleteSingle(fullPath, name); });
            $row.find('#chmod-btn').click(e => { e.stopPropagation(); self.chmodFile(fullPath, perm); });
            const $packBtn = $row.find('#unpack-pack-btn');
            if (name.endsWith('.tar.gz') || name.endsWith('.tgz')) {
                $packBtn.text('解压').off('click').on('click', e => { e.stopPropagation(); self.unpack(name); });
            } else {
                $packBtn.text('打包').off('click').on('click', e => { e.stopPropagation(); self.packSingle([name]); });
            }
            const editTypes = /\.(conf|txt|log|json|js|css|sh|lua|c|h|patch|ovpn|htm|html)$/i;
            const isConfigFile = self.currentPath === '/etc/config';
            editTypes.test(name) || isConfigFile ? $row.find('#edit-btn').show().click(e => {
                e.stopPropagation(); self.editorFile(fullPath);
            }) : $row.find('#edit-btn').hide();
            name.endsWith('.ipk') ? $row.find('#install-btn').show().click(e => {
                e.stopPropagation(); self.installIPK(fullPath);
            }) : $row.find('#install-btn').hide();
            $row.find('.fma-td-name').click(() => {
                if (self.selectMode) return;
                isDir ? self.loadFileList(fullPath) : window.open('/cgi-bin/luci/admin/nas/filemanager/open?path=' + encodeURIComponent(self.currentPath + '/') + '&filename=' + encodeURIComponent(name));
            });
            container.append($row);
        });
        self.exitSelectMode();
    },
    // ========== 面包屑导航 ==========
    Breadcrumb: function(path) {
        const container = $('#breadcrumb');
        container.empty();
        const parts = path.split('/').filter(Boolean);
        let current = '';
        const rootLink = $('<a href="javascript:void(0)"></a>')
            .text('根目录/')
            .data('path', '/');
        rootLink.click(function() {
            FileManager.loadFileList('/');
        });
        container.append(rootLink);
        parts.forEach(function(part) {
            current += '/' + part;
            const itemLink = $('<a href="javascript:void(0)"></a>')
                .text(part + '/')
                .data('path', current);
            itemLink.click(function() {
                FileManager.loadFileList($(this).data('path'));
            });
            container.append(itemLink);
        });
    },
    // ========== 文件操作 ==========
    /* 新建文件夹 */
    createFolder: async function() {
        const self = this;
        const folderName = prompt("输入文件夹名称", "新建文件夹");
        if (!folderName || folderName.trim() === "") return;
        const name = folderName.trim();
        try {
            const allow = await self.checkExists(self.currentPath, name, true);
            if (!allow) return;
            $.post("/cgi-bin/luci/admin/nas/filemanager/mkdir", {
                path: self.currentPath,
                name: name,
                overwrite: 1
            }, function() {
                self.loadFileList(self.currentPath);
            });
        } catch (err) {
            alert(err);
        }
    },
    /* 新建文件 */
    createFile: async function() {
        const self = this;
        const fileName = prompt("输入文件名称", "newfile.txt");
        if (!fileName || fileName.trim() === "") return;
        const name = fileName.trim();
        try {
            const allow = await self.checkExists(self.currentPath, name, false);
            if (!allow) return;
            $.post("/cgi-bin/luci/admin/nas/filemanager/mkfile", {
                path: self.currentPath,
                name: name,
                overwrite: 1
            }, function() {
                self.loadFileList(self.currentPath);
            });
        } catch (err) {
            alert(err);
        }
    },
    /* 上传文件/文件夹 */
    uploadFile: function(isDir) {
        const self = this;
        const input = $('<input type="file" ' + (isDir ? 'webkitdirectory directory multiple' : 'multiple') + '>');
        input.click();
        let currentXhr = null;

        input.change(async function(e) {
            const files = Array.from(e.target.files);
            if (!files.length) return;

            let progress = null;
            let uploadedTotal = 0;
            let index = 0;

            function startUpload() {
                if (progress.isCanceled() || index >= files.length) {
                    progress.finish();
                    return;
                }
                const file = files[index];
                const path = isDir ? file.webkitRelativePath : file.name;
                $('#progress-filename').text(path);
                $('#progress-stats').text((index + 1) + ' / ' + files.length);

                const fd = new FormData();
                fd.append('upload-file', file);
                fd.append('upload-filename', path);
                fd.append('upload-dir', self.currentPath + "/");

                currentXhr = new XMLHttpRequest();
                currentXhr.open('POST', '/cgi-bin/luci/admin/nas/filemanager/upload');
                currentXhr.upload.onprogress = function(e) {
                    if (e.lengthComputable) {
                        progress.update(uploadedTotal + e.loaded);
                    }
                };
                currentXhr.onload = function() {
                    uploadedTotal += file.size;
                    index++;
                    startUpload();
                };
                currentXhr.onerror = function() {
                    uploadedTotal += file.size;
                    index++;
                    startUpload();
                };
                currentXhr.send(fd);
            }

            if (isDir) {
                const firstFilePath = files[0].webkitRelativePath;
                const topFolderName = firstFilePath.split('/')[0];
                try {
                    const allow = await self.checkExists(self.currentPath, topFolderName, true);
                    if (!allow) return;
                } catch (err) {}
            } else {
                const allowedFiles = [];
                for (const file of files) {
                    try {
                        const allow = await self.checkExists(self.currentPath, file.name, false);
                        allow && allowedFiles.push(file);
                    } catch (err) {
                        allowedFiles.push(file);
                    }
                }
                if (!allowedFiles.length) return;
                files.length = 0;
                files.push(...allowedFiles);
            }

            progress = self.Progress({
                total: files.reduce((a, b) => a + b.size, 0),
                onComplete: () => self.loadFileList(self.currentPath)
            });
            startUpload();
        });
    },
    /* 复制选择项 */
    copySelected: function() {
        const list = [];
        $('.fma-check-item:checked').each(function(){ list.push($(this).data('path')); });
        this.clipboard = { mode: 'copy', list: list };
        this.exitSelectMode();
    },
    /* 剪切选择项 */
    cutSelected: function() {
        const list = [];
        $('.fma-check-item:checked').each(function(){ list.push($(this).data('path')); });
        this.clipboard = { mode: 'cut', list: list };
        this.exitSelectMode();
    },
    /* 粘贴 */
    paste: async function() {
        const self = this;
        if (!self.clipboard.mode || !self.clipboard.list.length) return;
        const pasteList = self.clipboard.list.slice();
        const total = pasteList.length;

        let progress = null;
        let idx = 0;

        async function doPaste() {
            if (idx >= total) {
                if (progress) progress.finish();
                if (self.clipboard.mode === 'cut') self.clipboard = { mode: null, list: [] };
                setTimeout(() => self.loadFileList(self.currentPath), 300);
                return;
            }

            const sourcePath = pasteList[idx];
            const fileName = sourcePath.split('/').pop();

            try {
                const allow = await self.checkExists(self.currentPath, fileName, false);
                if (!allow) {
                    idx++;
                    if (progress) progress.update(idx);
                    doPaste();
                    return;
                }

                if (!progress) {
                    progress = self.Progress({
                        total: total,
                        onComplete: () => {
                            if (self.clipboard.mode === 'cut') self.clipboard = { mode: null, list: [] };
                            self.loadFileList(self.currentPath);
                        }
                    });
                }

                $.post('/cgi-bin/luci/admin/nas/filemanager/paste', {
                    mode: self.clipboard.mode,
                    source: sourcePath,
                    target: self.currentPath
                }, () => {
                    idx++;
                    progress.update(idx);
                    doPaste();
                });
            } catch (err) {
                idx++;
                if (progress) progress.update(idx);
                doPaste();
            }
        }

        doPaste();
    },
    /* 删除单个目录/文件 */
    deleteSingle: function(p, n) {
        if (!confirm("确定删除 " + n + "？")) return;
        const self = this;
        $.post('/cgi-bin/luci/admin/nas/filemanager/delete', {
            path: self.currentPath, files: n
        }, function() {
            self.loadFileList(self.currentPath);
        });
    },
    /* 删除选择项 */
    deleteSelected: function() {
        if (!confirm("确定删除选中项？")) return;
        const self = this;
        $('.fma-check-item:checked').each(function() {
            $.post('/cgi-bin/luci/admin/nas/filemanager/delete', {
                path: self.currentPath, files: $(this).data('name')
            });
        });
        setTimeout(function(){ self.loadFileList(self.currentPath); }, 300);
    },
    /* 打包单个目录/文件 */
    packSingle: function(nameList) {
        if (!nameList || !nameList.length) return;
        const self = this;
        const progress = self.Progress({
            total: 1,
            onComplete: () => self.loadFileList(self.currentPath)
        });
        $('#progress-filename').text('打包中...');
        const params = { path: this.currentPath, files: nameList.join('\n') };
        if (nameList.length === 1) params.filename = nameList[0];
        $.post('/cgi-bin/luci/admin/nas/filemanager/pack', params, function(res) {
            if (res && res.ec !== 0) alert('打包失败！');
            progress.finish();
        }).fail(() => progress.finish());
    },
    /* 打包选择项 */
    packSelected: function() {
        const nameList = [];
        $('.fma-check-item:checked').each(function() {
            nameList.push($(this).data('name'));
        });
        this.packSingle(nameList);
    },
    /* 解压 */
    unpack: async function(name) {
        const self = this;
        const targetName = name.replace(/\.tar\.gz$/i, '').replace(/\.tgz$/i, '');
        try {
            const allow = await self.checkExists(self.currentPath, targetName, false);
            if (!allow) return;
            const progress = self.Progress({
                total: 1,
                onComplete: () => self.loadFileList(self.currentPath)
            });
            $('#progress-filename').text('解压中...');
            $.post('/cgi-bin/luci/admin/nas/filemanager/unpack', {
                source: self.currentPath + '/' + name
            }, function(res) {
                if (res && res.ec !== 0) alert('解压失败！');
                progress.finish();
            }).fail(() => {
                alert('解压失败');
                progress.finish();
            });
        } catch (err) {
            alert('检查失败，解压终止');
        }
    },
    /* 重命名 */
    renameFile: async function(p, o) {
        let n = prompt("新名称", o);
        if (!n || n === o) return;
        const self = this;
        const newName = n.trim();
        try {
            const allow = await self.checkExists(self.currentPath, newName, false);
            if (!allow) return;
            $.post('/cgi-bin/luci/admin/nas/filemanager/rename', {
                filepath: p, 
                newpath: self.currentPath + "/" + newName
            }, function() {
                self.loadFileList(self.currentPath);
            });
        } catch (err) {
            alert(err);
        }
    },
    /* 设置权限 */
    chmodFile: function(path, currentPerm) {
        let perm = prompt("设置文件权限（如 755、644、777）", currentPerm);
        if (perm === null) return;
        perm = perm.trim();
        if (!perm || !/^[0-7]{3}$/.test(perm)) {
            alert("请输入正确的 3 位数字权限！");
            return;
        }
        const self = this;
        $.post("/cgi-bin/luci/admin/nas/filemanager/chmod", {
            path: path,
            perm: perm
        }, function() {
            self.loadFileList(self.currentPath);
        });
    },
    /* 命令终端 */
    Terminal: function() {
        const self = this;
        let currentPath = this.currentPath || "/";
        let rootPass = null;
        const $term = $(document.getElementById('terminal-template').content.cloneNode(true).firstElementChild);
        const $output = $term.find("#term-output");
        let inputBuffer = "";
        
        const commandHistory = [];
        let historyIndex = -1;
        let tempInput = "";

        function focusAndScroll() {
            const el = $output[0];
            el.scrollTop = el.scrollHeight;
            const sel = window.getSelection();
            const range = document.createRange();
            range.selectNodeContents(el);
            range.collapse(false);
            sel.removeAllRanges();
            sel.addRange(range);
            el.focus();
        }

        function getPrompt() {
            return rootPass ? `root@OpenWrt:${currentPath}# ` : "Password: ";
        }

        function prompt() {
            $output.append(rootPass ? getPrompt() : "OpenWrt login: root\nPassword: ");
            focusAndScroll();
        }

        function run(cmd) {
            if (!cmd && rootPass) { prompt(); return; }
            const lines = cmd.split('\n');
            if (lines.length > 1) {
                run(lines[0]);
                setTimeout(() => run(lines.slice(1).join('\n')), 0);
                return;
            }

            const actualCmd = rootPass && cmd.trim().startsWith("cd") ? cmd.trim() + " && pwd" : cmd;

            $.post("/cgi-bin/luci/admin/nas/filemanager/cmd", {
                path: currentPath,
                cmd: actualCmd,
                pwd: rootPass || cmd
            }, function(res) {
                if (res.ec === 401) {
                    $output.append("\nLogin incorrect\n");
                    rootPass = null;
                    inputBuffer = "";
                    prompt();
                    return;
                }

                if (!rootPass) {
                    rootPass = cmd;
                    $output.append("\n");
                } else {
                    $output.append("\n");
                    const output = res.output || "";
                    
                    if (cmd.trim().startsWith("cd") && output) {
                        const newPath = output.trim();
                        if (newPath.startsWith("/")) currentPath = newPath;
                    } else if (output) {
                        $output.append(output);
                        if (output.slice(-1) !== "\n") $output.append("\n");
                    }
                }

                inputBuffer = "";
                prompt();
            }, "json");

            if (rootPass && cmd.trim()) {
                commandHistory.push(cmd.trim());
                historyIndex = commandHistory.length;
            }
        }

        $output.attr("contenteditable", true).on("keydown", function(e) {
            e.stopPropagation();
            if (e.key === "Enter") {
                e.preventDefault();
                run(inputBuffer);
            } else if (e.key === "Backspace" && inputBuffer.length === 0) {
                e.preventDefault();
            } 
            else if (e.key === "ArrowUp" && rootPass) {
                e.preventDefault();
                if (historyIndex > 0) {
                    if (historyIndex === commandHistory.length) {
                        tempInput = inputBuffer;
                    }
                    historyIndex--;
                    inputBuffer = commandHistory[historyIndex];
                    updateInputLine();
                }
            } else if (e.key === "ArrowDown" && rootPass) {
                e.preventDefault();
                if (historyIndex < commandHistory.length - 1) {
                    historyIndex++;
                    inputBuffer = commandHistory[historyIndex];
                    updateInputLine();
                } else if (historyIndex === commandHistory.length - 1) {
                    historyIndex = commandHistory.length;
                    inputBuffer = tempInput;
                    updateInputLine();
                }
            }
        }).on("input", function() {
            const fullText = $output.text();
            const lastLine = fullText.slice(fullText.lastIndexOf('\n') + 1);
            inputBuffer = lastLine.startsWith(getPrompt()) ? lastLine.slice(getPrompt().length) : "";
            focusAndScroll();
        }).on("paste", function(e) {
            e.stopPropagation();
            focusAndScroll();
        });

        function updateInputLine() {
            const fullText = $output.text();
            const lastLineStart = fullText.lastIndexOf('\n') + 1;
            const promptStr = getPrompt();
            $output.text(fullText.slice(0, lastLineStart) + promptStr + inputBuffer);
            focusAndScroll();
        }

        $term.find("#term-close").click(() => {
            $term.remove();
            self.loadFileList(self.currentPath);
        });
        $("body").append($term);
        prompt();
    },
    /* 安装插件 */
    installIPK: function(p) {
        const self = this;
        if (!confirm("确定安装此 IPK 插件？\n" + p)) return;
        $.ajax({
            url: '/cgi-bin/luci/admin/nas/filemanager/install',
            type: 'POST',
            data: { filepath: p },
            dataType: 'text',
            success: function(res) {
                if (res.indexOf("Configuring") !== -1 || (res.indexOf("Installing") !== -1 && res.indexOf("Collected errors") === -1)) {
                    alert("✅安装成功：\n\n" + res);
                } else {
                    alert("❌安装失败：\n\n" + res);
                }
            },
            error: function(xhr) {
                alert("❌安装失败：\n\n" + xhr.responseText);
            },
            complete: function() {
                self.loadFileList(self.currentPath);
            }
        });
    },
    /* 编辑文件 */
    editorFile: function(p) {
        const self = this;
        const xhr = new XMLHttpRequest();
        xhr.open('GET', '/cgi-bin/luci/admin/nas/filemanager/edit?path=' + encodeURIComponent(p));
        xhr.onload = function() {
            try {
                const res = JSON.parse(xhr.responseText);
                if (res.ec !== 0) {
                    alert("读取文件失败");
                    return;
                }
                const original = res.content;
                const template = document.getElementById('editor-template');
                const fragment = template.content.cloneNode(true);
                const $editor = $(fragment.firstElementChild);
                const $title = $editor.find('#fma-editor-title');
                const $textarea = $editor.find('#fma-editor-textarea');
                const $findInput = $editor.find('#fma-editor-find-input');
                const $replaceInput = $editor.find('#fma-editor-replace-input');
                const $findBtn = $editor.find('#fma-editor-find-btn');
                const $replaceBtn = $editor.find('#fma-editor-replace-btn');
                const $replaceAllBtn = $editor.find('#fma-editor-replace-all-btn');
                const $cancelBtn = $editor.find('#fma-editor-cancel-btn');
                const $saveBtn = $editor.find('#fma-editor-save-btn');
                $title.text('编辑：' + p.split('/').pop());
                $textarea.val(original);
                function getTextWidth(text, font) {
                    const span = document.createElement('span');
                    span.style.font = font;
                    span.style.visibility = 'hidden';
                    span.style.position = 'absolute';
                    span.style.whiteSpace = 'pre'; 
                    span.textContent = text;
                    document.body.appendChild(span);
                    const width = span.offsetWidth;
                    document.body.removeChild(span);
                    return width;
                }
                let findPos = 0, lastSearch = '';
                $findInput.keydown((e) => {
                    if (e.key === 'Enter') { e.preventDefault(); $findBtn.click(); }
                });
                $replaceInput.keydown((e) => {
                    if (e.key === 'Enter') { e.preventDefault(); $replaceBtn.click(); }
                });
                $findBtn.click(() => {
                    const key = $findInput.val().trim();
                    if (!key) return alert('请输入查找内容');
                    const val = $textarea.val();
                    if (key !== lastSearch) { lastSearch = key; findPos = 0; }
                    const idx = val.indexOf(key, findPos);
                    if (idx === -1) { findPos = 0; return alert('已搜索到末尾'); }
                    $textarea.focus();
                    $textarea[0].setSelectionRange(idx, idx + key.length);
                    const lineHeight = $textarea[0].scrollHeight / (val.split('\n').length || 1);
                    const targetLine = val.substring(0, idx).split('\n').length - 1;
                    $textarea[0].scrollTop = targetLine * lineHeight - $textarea[0].clientHeight / 2;
                    const lines = val.split('\n');
                    const targetLineText = lines[targetLine];
                    const lineStart = lines.slice(0, targetLine).reduce((acc, line) => acc + line.length + 1, 0);
                    const col = idx - lineStart;
                    const textBeforeKey = targetLineText.substring(0, col);
                    const textWidth = getTextWidth(textBeforeKey, getComputedStyle($textarea[0]).font);
                    const targetScrollLeft = textWidth - $textarea[0].clientWidth / 2;
                    $textarea[0].scrollLeft = Math.max(0, targetScrollLeft);
                    findPos = idx + key.length;
                });
                $replaceBtn.click(() => {
                    const key = $findInput.val().trim();
                    const val = $replaceInput.val();
                    if (!key) return alert('请先输入查找内容');
                    const s = $textarea[0].selectionStart, e = $textarea[0].selectionEnd;
                    if (s === e) return alert('请先点击查找下一个');
                    const selectedText = $textarea.val().substring(s, e);
                    if (selectedText === key) {
                        $textarea.val($textarea.val().slice(0, s) + val + $textarea.val().slice(e));
                        $textarea[0].setSelectionRange(s, s + val.length);
                    } else {
                        alert('当前选中内容与查找关键词不匹配，无法替换');
                    }
                    $textarea.focus();
                });
                $replaceAllBtn.click(() => {
                    const key = $findInput.val().trim();
                    const val = $replaceInput.val();
                    if (!key) return alert('请先输入查找内容');
                    const escapedKey = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                    const regex = new RegExp(escapedKey, 'g');
                    const totalCount = ($textarea.val().match(regex) || []).length;
                    if (totalCount === 0) return alert('未找到匹配内容');
                    $textarea.val($textarea.val().replace(regex, val));
                    alert('全部替换完成，共替换 ' + totalCount + ' 处');
                    $textarea.focus();
                });
                $cancelBtn.click(() => { $editor.remove(); });
                $textarea.on('input', () => {
                    $saveBtn.prop('disabled', $textarea.val() === original);
                });
                $saveBtn.click(() => {
                    const xhrSave = new XMLHttpRequest();
                    xhrSave.open('POST', '/cgi-bin/luci/admin/nas/filemanager/edit');
                    const formData = new FormData();
                    formData.append('path', p);
                    formData.append('content', $textarea.val());
                    xhrSave.onload = () => {
                        try {
                            const saveRes = JSON.parse(xhrSave.responseText);
                            if (saveRes.ec === 0) alert("保存成功");
                            else alert("保存失败：" + (saveRes.error || "未知错误"));
                        } catch (e) { alert("保存失败：服务器返回格式异常"); }
                        $editor.remove();
                    };
                    xhrSave.onerror = () => { alert("保存失败：网络请求异常"); $editor.remove(); };
                    xhrSave.send(formData);
                });
                $('body').append($editor);
            } catch (e) { alert("编辑器加载异常：" + e); }
        };
        xhr.onerror = function() { alert("请求失败"); };
        xhr.send();
    },
};

window.addEventListener('popstate', function() {
    const path = (history.state && history.state.path) || '/';
    FileManager.loadFileList(path);
});

$(function() { FileManager.init(); });