function init_itoggle(id, func) {
    var obj_f = $j('#' + id + '_fake'),
        obj_0 = $j('#' + id + '_0'),
        obj_1 = $j('#' + id + '_1');

    obj_f.change(function (e) {
        if ($j(e.target).prop("checked") == true) {
            $j(e.target).attr("value", 1);
            obj_1.attr("checked", "checked");
            obj_0.removeAttr("checked");
            if (typeof (func) === 'function')
                func();
        }
        else {
            $j(e.target).attr("value", 0);
            obj_0.attr("checked", "checked");
            obj_1.removeAttr("checked");
            if (typeof (func) === 'function')
                func();
        }
    }).simpleSwitch({
        "theme": "DefaultMin"
    });
}
