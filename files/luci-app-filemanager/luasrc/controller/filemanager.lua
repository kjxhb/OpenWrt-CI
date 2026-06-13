module("luci.controller.filemanager", package.seeall)

function index()
    page = entry({"admin", "nas", "filemanager"}, template("filemanager"), _("文件管理"), 1)
    page.i18n = "base"
    page.dependent = true
    page.acl_depends = { "luci-app-filemanager" }

    page = entry({"admin", "nas", "filemanager", "list"}, call("filemanager_list"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "open"}, call("filemanager_open"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "delete"}, call("filemanager_delete"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "rename"}, call("filemanager_rename"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "mkdir"}, call("filemanager_mkdir"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "mkfile"}, call("filemanager_mkfile"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "copy"}, call("filemanager_copy"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "cut"}, call("filemanager_cut"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "paste"}, call("filemanager_paste"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "pack"}, call("filemanager_pack"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "unpack"}, call("filemanager_unpack"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "chmod"}, call("filemanager_chmod"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "upload"}, call("filemanager_upload"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "install"}, call("filemanager_install"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "edit"}, call("filemanager_edit"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "check_exists"}, call("filemanager_check_exists"), nil)
    page.leaf = true
    page = entry({"admin", "nas", "filemanager", "cmd"}, call("filemanager_cmd"), nil)
    page.leaf = true
end
-- 文件目录列表
function filemanager_list()
    local path = luci.http.formvalue("path")
    list_response(path, true)
end

-- 目录扫描
function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local dir = directory:gsub("/$", "")
    local full_dir = dir .. "/"
    local pfile = popen("ls -lh \""..full_dir.."\" 2>/dev/null")
    
    for fileinfo in pfile:lines() do
        if fileinfo ~= "" then
            i = i + 1
            local raw_type = string.sub(fileinfo, 1, 1)
            local link_target = nil
            local is_dir_link = false

            local linkindex, _, linkpath = string.find(fileinfo, "->%s+(.+)$")
            if linkindex then
                local finalpath
                if string.sub(linkpath, 1, 1) == "/" then
                    finalpath = linkpath
                else
                    finalpath = nixio.fs.realpath(full_dir .. linkpath)
                end
       
                if finalpath and nixio.fs.stat(finalpath) then
                    is_dir_link = nixio.fs.stat(finalpath, "type") == "dir"
                end

                if is_dir_link then
                    t[i] = "z" .. string.sub(fileinfo, 2)
                else
                    t[i] = fileinfo
                end
            else
                t[i] = fileinfo
            end
        end
    end
    pfile:close()
    collectgarbage()
    return t
end
-- 列表响应
function list_response(path, success)
    luci.http.prepare_content("application/json")
    local result
    if success then
        local rv = scandir(path)
        result = { ec = 0, data = rv }
    else
        result = { ec = 1 }
    end
    luci.http.write_json(result)
end
-- 打开/预览/下载
function filemanager_open()
    local path = luci.http.formvalue("path")
    local filename = luci.http.formvalue("filename")
    local file = path .. filename
    local download_fpi = io.open(file, "r")
    if not download_fpi then
        luci.http.status(404, "File not found")
        return
    end

    local mime = to_mime(filename)
    if mime:match("^text/") then
        luci.http.header('Content-Disposition', 'inline; filename="' .. filename .. '"')
        luci.http.prepare_content(mime .. "; charset=utf-8")
    else
        luci.http.header('Content-Disposition', 'attachment; filename="' .. filename .. '"')
        luci.http.prepare_content(mime)
    end

    luci.ltn12.pump.all(luci.ltn12.source.file(download_fpi), luci.http.write)
    download_fpi:close()
    collectgarbage("collect")
end
-- 删除
function filemanager_delete()
    local path = luci.http.formvalue("path")
    local files = luci.http.formvalue("files") or ""
    local ok = true
    local fileList = luci.util.split(files, "\n")
    for _, name in ipairs(fileList) do
        name = name:trim()
        if name ~= "" then
            local fp = path .. "/" .. name
            if nixio.fs.stat(fp, "type") == "dir" then
                os.execute('rm -rf "' .. fp .. '"')
            else
                os.remove(fp)
            end
        end
    end
    collectgarbage("collect")
    list_response(path, ok)
end
-- 重命名
function filemanager_rename()
    local filepath = luci.http.formvalue("filepath")
    local newpath = luci.http.formvalue("newpath")
    local success = os.execute('mv "'..filepath..'" "'..newpath..'"')
    collectgarbage("collect")
    list_response(nixio.fs.dirname(filepath), success)
end
-- 新建文件夹
function filemanager_mkdir()
    local path = luci.http.formvalue("path") or "/"
    local name = luci.http.formvalue("name") or ""
    local overwrite = luci.http.formvalue("overwrite") or "0"
    if name == "" then
        list_response(path, false)
        return
    end
    local fullpath = path .. "/" .. name
    fullpath = fullpath:gsub("'", "'\\''")
    if overwrite == "1" and nixio.fs.stat(fullpath) then
        os.execute('rm -rf "' .. fullpath .. '"')
    end
    local ok = os.execute('mkdir -p "' .. fullpath .. '"')
    collectgarbage("collect")
    list_response(path, ok)
end
-- 新建文件
function filemanager_mkfile()
    local path = luci.http.formvalue("path") or "/"
    local name = luci.http.formvalue("name") or ""
    local overwrite = luci.http.formvalue("overwrite") or "0"
    local suc = false
    if name == "" then
        list_response(path, false)
        return
    end
    local fullpath = path .. "/" .. name
    fullpath = fullpath:gsub("'", "'\\''")
    if overwrite == "1" and nixio.fs.stat(fullpath) then
        os.remove(fullpath)
    end
    local f = io.open(fullpath, "w")
    if f then
        f:write("")
        f:close()
        suc = true
    end
    collectgarbage("collect")
    list_response(path, suc)
end
-- 复制
function filemanager_copy()
    json_response({
        ec = 0,
        mode = "copy",
        source = luci.http.formvalue("source"),
        isdir = luci.http.formvalue("isdir")
    })
end
-- 剪切
function filemanager_cut()
    json_response({
        ec = 0,
        mode = "cut",
        source = luci.http.formvalue("source"),
        isdir = luci.http.formvalue("isdir")
    })
end
-- 粘贴
function filemanager_paste()
    local source = luci.http.formvalue("source") or ""
    local target = luci.http.formvalue("target") or "/"
    local mode = luci.http.formvalue("mode") or "copy"
    local isdir_str = luci.http.formvalue("isdir") or ""
    local src_list = luci.util.split(source, "\n")
    local isdir_list = luci.util.split(isdir_str, "\n")
    local success = 0
    local total = #src_list
    for i, s in ipairs(src_list) do
        s = s:trim()
        if s ~= "" then
            local isdir = isdir_list[i] or "0"
            local cmd
            if mode == "copy" then
                cmd = isdir == "1"
                    and string.format('cp -rf "%s" "%s/"', s, target)
                    or string.format('cp -f "%s" "%s/"', s, target)
            elseif mode == "cut" then
                cmd = string.format('mv -f "%s" "%s/"', s, target)
            end
            if cmd and os.execute(cmd) then success = success + 1 end
        end
    end
    collectgarbage("collect")
    json_response({
        ec = success > 0 and 0 or 1,
        msg = string.format("成功 %d/%d", success, total),
        data = target
    })
end
-- 打包
function filemanager_pack()
    local path = luci.http.formvalue("path") or "/"
    local files = luci.http.formvalue("files") or ""
    local filename = luci.http.formvalue("filename")
    local fileList = luci.util.split(files, "\n")
    local ok = false
    local pkgName

    if filename and filename ~= "" then
        pkgName = filename .. ".tar.gz"
    else
        local timeStr = os.time()
        pkgName = "pack_" .. timeStr .. ".tar.gz"
    end

    local args = ""
    for _, name in ipairs(fileList) do
        name = name:trim()
        if name ~= "" then
            args = args .. " '" .. name:gsub("'", "") .. "'"
        end
    end

    if args ~= "" then
        local cmd = string.format('cd "%s" && tar -zcf "%s" %s', path, pkgName, args)
        ok = os.execute(cmd)
    end
    collectgarbage("collect")
    list_response(path, ok)
end
-- 解压
function filemanager_unpack()
    local src = luci.http.formvalue("source")
    local dir = nixio.fs.dirname(src)
    local ok = os.execute('tar -zxf "' .. src .. '" -C "' .. dir .. '"')
    collectgarbage("collect")
    list_response(dir, ok)
end
-- 权限
function filemanager_chmod()
    local path = luci.http.formvalue("path")
    local perm = luci.http.formvalue("perm")
    local ok = os.execute('chmod ' .. perm .. ' "' .. path .. '"')
    collectgarbage("collect")
    list_response(nixio.fs.dirname(path), ok)
end
-- 上传文件
function filemanager_upload()
    local dir = luci.http.formvalue("upload-dir")
    local name = luci.http.formvalue("upload-filename")
    local path = dir .. name
    local fp = nil

    local dir_path = nixio.fs.dirname(path)
    if dir_path and dir_path ~= dir then
        os.execute('mkdir -p "' .. dir_path .. '"')
    end

    luci.http.setfilehandler(function(meta, chunk, eof)
        if not fp and meta and meta.name == "upload-file" then
            fp = io.open(path, "wb")
        end
        if fp and chunk then
            fp:write(chunk)
        end
        if fp and eof then
            fp:close()
            fp = nil
        end
    end)

    collectgarbage("collect")
    list_response(dir, true)
end
-- 安装ipk
function filemanager_install()
    local filepath = luci.http.formvalue("filepath")
    filepath = filepath:gsub("'", "'\\''")
    local result = io.popen("opkg install --force-overwrite '" .. filepath .. "' 2>&1"):read("*a")
    luci.http.prepare_content("text/plain")
    luci.http.write(result)
end
-- 编辑
function filemanager_edit()
    local path = luci.http.formvalue("path")
    local content = luci.http.formvalue("content")
    if not path then
        luci.http.prepare_content("application/json")
        luci.http.write_json({ ec = 1 })
        return
    end
    if content ~= nil then
        local f = io.open(path, "w")
        if f then
            f:write(content)
            f:close()
        end
        luci.http.prepare_content("application/json")
        luci.http.write_json({ ec = 0 })
        collectgarbage("collect")
        return
    end
    local file_content = ""
    local f = io.open(path, "r")
    if f then
        file_content = f:read("*a")
        f:close()
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json({ ec = 0, content = file_content })
    collectgarbage("collect")
end
-- 命令终端
function filemanager_cmd()
    local pwd = luci.http.formvalue("pwd") or ""
    local path = luci.http.formvalue("path") or "/"
    local cmd = luci.http.formvalue("cmd") or ""

    if not luci.sys.user.checkpasswd("root", pwd) then
        luci.http.write_json({ ec = 401 })
        return
    end

    -- 保留原有执行方式（与原代码行为完全一致）
    local full_cmd = string.format('cd "%s" 2>/dev/null && %s 2>&1', path:gsub('"', '\\"'), cmd:gsub('"', '\\"'))
    local result = io.popen(full_cmd):read("*a")

    luci.http.write_json({ ec = 0, output = result })
end
-- 同名检查
function filemanager_check_exists()
    local path = luci.http.formvalue("path") or "/"
    local name = luci.http.formvalue("name") or ""
    local isdir = luci.http.formvalue("isdir") or "0"
    local fullpath = path .. "/" .. name
    fullpath = fullpath:gsub("//", "/")
    local exists = nixio.fs.stat(fullpath) and 1 or 0
    luci.http.prepare_content("application/json")
    luci.http.write_json({ ec = 0, exists = exists })
end
-- 返回 MIME 类型
function to_mime(filename)
    local MIME_TYPES = {
        ["txt"]="text/plain",["conf"]="text/plain",["ovpn"]="text/plain",["log"]="text/plain",
        ["js"]="text/javascript",["json"]="application/json",["css"]="text/css",
        ["htm"]="text/html",["html"]="text/html",
        ["bmp"]="image/bmp",["gif"]="image/gif",["png"]="image/png",["jpg"]="image/jpeg",["jpeg"]="image/jpeg",
        ["zip"]="application/zip",["pdf"]="application/pdf",["tar"]="application/x-tar",["gz"]="application/gzip",
        ["ipk"]="application/x-deb"
    }
    if type(filename) == "string" then
        local ext = filename:match("[^%.]+$")
        if ext and MIME_TYPES[ext:lower()] then
            return MIME_TYPES[ext:lower()]
        end
    end
    return "application/octet-stream"
end
-- 统一JSON响应
function json_response(tbl)
    luci.http.prepare_content("application/json")
    luci.http.write_json(tbl)
end