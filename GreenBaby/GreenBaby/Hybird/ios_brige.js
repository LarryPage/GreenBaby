/**
 * Created by 李香成 on 2019/3/18.
 */

__functionIndexMap = {};

function calliOSFunction(namespace, functionName, args, callback) {
    if (!window.webkit.messageHandlers[namespace]) return;
    var wrap = {
        "method": functionName,
        "params": args
    };
    if (callback) {
        var callbackFuncName;
        if (typeof callback == 'function') {
            callbackFuncName = createCallbackFunction(functionName + "_" + "callback", callback);
        } else {
            callbackFuncName = callback;
        }
        wrap["callback"] = callbackFuncName
    }
    window.webkit.messageHandlers[namespace].postMessage(JSON.stringify(wrap));
}

function createCallbackFunction(funcName, callbackFunc) {
    if (callbackFunc && callbackFunc.name != null && callbackFunc.name.length > 0) {
        return callbackFunc.name;
    }

    if (typeof window[funcName + 0] != 'function') {
        window[funcName + 0] = callbackFunc;
        __functionIndexMap[funcName] = 0;
        return funcName + 0
    } else {
        var maxIndex = __functionIndexMap[funcName];
        var newIndex = ++maxIndex;
        window[funcName + newIndex] = callbackFunc;
        return funcName + newIndex;
    }
}


var BRC = {};

//******************Hybrid方法******************//
//****************1.页面跳转的控制****************//
BRC.pushWebView = function (params) {
    calliOSFunction("BRC", "pushWebView", params, null);
};

BRC.popWebView = function (params) {
    calliOSFunction("BRC", "popWebView", params, null);
};

BRC.backWebView = function (params) {
    calliOSFunction("BRC", "backWebView", params, null);
};
//****************2.功能性接口*******************//
BRC.setWebViewTag = function (params) {
    calliOSFunction("BRC", "setWebViewTag", params, null);
};

BRC.checkWebView = function (params,callBackName) {
    calliOSFunction("BRC", "checkWebView", params, callBackName);
};

BRC.setBounces = function (params) {
    calliOSFunction("BRC", "setBounces", params, null);
};

BRC.getUserInfo = function (callBackName) {
    calliOSFunction("BRC", "getUserInfo", null, callBackName);
};

BRC.showLogin = function () {
    calliOSFunction("BRC", "showLogin", null, null);
};

BRC.execApiRequest = function (params,callBackName) {
    calliOSFunction("BRC", "execApiRequest", params, callBackName);
};
//****************3.cache相关*******************//
BRC.writeCache = function (params) {
    calliOSFunction("BRC", "writeCache", params, null);
};

BRC.readCache = function (params,callBackName) {
    calliOSFunction("BRC", "readCache", params, callBackName);
};

BRC.removeCache = function (params) {
    calliOSFunction("BRC", "removeCache", params, null);
};

BRC.removeAllCache = function () {
    calliOSFunction("BRC", "removeAllCache", null, null);
};
//****************4.Session相关*******************//
BRC.writeSession = function (params) {
    calliOSFunction("BRC", "writeSession", params, null);
};

BRC.readSession = function (params,callBackName) {
    calliOSFunction("BRC", "readSession", params, callBackName);
};

BRC.removeSession = function (params) {
    calliOSFunction("BRC", "removeSession", params, null);
};

BRC.removeAllSession = function () {
    calliOSFunction("BRC", "removeAllSession", null, null);
};
//****************5.上导航 Title Bar*****************//
BRC.showTitleBar = function (params) {
    calliOSFunction("BRC", "showTitleBar", params, null);
};

BRC.setTitleBar = function (params) {
    calliOSFunction("BRC", "setTitleBar", params, null);
};

BRC.setLeftButton = function (params) {
    calliOSFunction("BRC", "setLeftButton", params, null);
};

BRC.setRightButton = function (params) {
    calliOSFunction("BRC", "setRightButton", params, null);
};

BRC.setRightButtonShare = function (params) {
    calliOSFunction("BRC", "setRightButtonShare", params, null);
};
//********************************************//

window["BRC"] = BRC;
