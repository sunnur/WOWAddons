
local guideData = {


    {
           {
               close = "any",
               text = "看到自己走在归乡路上。",
               bear = {img = "4.png", anchor = {0.5, 0.5}},
               box = {vertical="center", offsetY = 50, horizontal = "right" ,offsetX = 46}
           },
           {
               item = {{6,3}, {5,3},{5,2},  {5,4}},
               close = "elimi",
               text = "你站在，夕阳下面，容颜娇艳。",
               bear = {img = "3.png"},
               box = {vertical="top", offsetY= 30, horizontal = "left", offsetX = 46}
           },
           {
               item = {{3, 5},{3, 6},  {2, 5}, {4,5}},
               close = "elimi",
               text = "那是你，衣裙漫飞。",
               bear = {img = "5.png"},
               box = {vertical="top", offsetY= 50, horizontal = "left", offsetX = 46}
           },
   
   
           {
               goal = true,
               close = "any",
               text = "那是你，温柔如水。",
               bear = {img = "4.png"},
               box = {vertical="center", offsetY= 20, horizontal = "right", offsetX = 46}
           }
       }
   }
   
   
   function getIndentSpace(indent)
        local str = ""
        for i =1, indent do
             str = str .. " "
        end
        return str
   end
   
   
   function newLine(indent)
        local str = "\n"
        str = str .. getIndentSpace(indent)
        return str
   end
   
   
   function createKeyVal(key, value, bline, deep, indent)
        local str = "";
        if (bline[deep]) then
        str = str .. newLine(indent)
        end
        if type(key) == "string" then
             str = str.. key .. " = "
        end
        if type(value) == "table" then
             str = str .. getTableStr(value, bline, deep+1, indent)
        elseif type(value) == "string" then
             str = str .. '"' .. tostring(value) .. '"'
   
   
        else
             str = str ..tostring(value)
        end
        str = str .. ","
        return str
   end
   
   
   function getTableStr(t, bline, deep, indent)
   
   
        local str
        if bline[deep] then
             str = newLine(indent) .. "{"
             indent = indent + 4
        else
             str = "{"
        end
   
   
        for key, val in pairs(t) do
             str = str .. createKeyVal(key, val, bline, deep, indent)
        end
        if bline[deep] then
             indent = indent-4
             str = str .. newLine(indent) .. "}"
        else
             str = str .. "}"
        end
        return str
   end
   
   
   function printtable(t)
        local str = getTableStr(t, {true, true, true}, 1, 0)
        print(str)
   end
   
   
   printtable(guideData)
   ————————————————
   版权声明：本文为CSDN博主「booirror」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
   原文链接：https://blog.csdn.net/booirror/article/details/47075505