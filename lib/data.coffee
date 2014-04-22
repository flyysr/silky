###
    读取.silky下的json文件，用这个数据来渲染handlebars
###
_fs = require 'fs'
_path = require 'path'
_common = require './common'

_isWatch = false        #是否在监控中
_data = {
    json: {},
    less: {}
}

#根据文件名获取key
getDataKey = (file)->
    _path.basename file, _path.extname(file)

#读取json数据到_data中
readData = (file)->
    #只处理json和less的文件
    extname = _path.extname(file).replace('.', '')
    return if extname not in ['json', 'less']

    #读取
    content = _fs.readFileSync(file, 'utf-8')
    key = getDataKey file

    #将数据存入
    _data[extname][key] = (if extname is 'json' then JSON.parse(content) else content)

#获取数据所在的目录
getDataPath = ()->
    #设置data的主目录，development以后需要从命令行参数中获取
    _path.join _common.root(), '.silky', 'development'

#读取所有的文件到data中，并返回
fetch = ()->
    #循环读取所有数据到缓存中
    _fs.readdirSync(getDataPath()).forEach (filename)->
        readData _path.join(getDataPath(), filename)

#监控文件
watch = ()->
    return if _isWatch
    _isWatch = true

    #监控json和less是否发生的变化，如果有变化，则实时
    _common.watch getDataPath(), /\.(json|less)$/i, (event, file)->
        extname = _path.extname(file).replace '.', ''
        #删除数据
        if event is 'delete'
            key = getDataKey file
            delete _data[extname][key]
        else
            #更新数据
            readData file

        #触发全局事件，重新刷新客户端的数据
        _common.onPageChanged()
        
#入口
exports.init = ()->
    fetch()
    watch()

exports.whole = _data


