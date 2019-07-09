/**
 * Created by 李香成 on 2019/3/18.
 */

__functionIndexMap = {};

function callIOSFunction(namespace, functionName, args, callback) {
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
    callIOSFunction("BRC", "pushWebView", params, null);
};

BRC.popWebView = function (params) {
    callIOSFunction("BRC", "popWebView", params, null);
};

BRC.backWebView = function (params) {
    callIOSFunction("BRC", "backWebView", params, null);
};
//****************2.功能性接口*******************//
BRC.setWebViewTag = function (params) {
    callIOSFunction("BRC", "setWebViewTag", params, null);
};

BRC.checkWebView = function (params,callBackName) {
    callIOSFunction("BRC", "checkWebView", params, callBackName);
};

BRC.setBounces = function (params) {
    callIOSFunction("BRC", "setBounces", params, null);
};

BRC.getUserInfo = function (callBackName) {
    callIOSFunction("BRC", "getUserInfo", null, callBackName);
};

BRC.showLogin = function () {
    callIOSFunction("BRC", "showLogin", null, null);
};

BRC.execApiRequest = function (params,callBackName) {
    callIOSFunction("BRC", "execApiRequest", params, callBackName);
};
//****************3.cache相关*******************//
BRC.writeCache = function (params) {
    callIOSFunction("BRC", "writeCache", params, null);
};

BRC.readCache = function (params,callBackName) {
    callIOSFunction("BRC", "readCache", params, callBackName);
};

BRC.removeCache = function (params) {
    callIOSFunction("BRC", "removeCache", params, null);
};

BRC.removeAllCache = function () {
    callIOSFunction("BRC", "removeAllCache", null, null);
};
//****************4.Session相关*******************//
BRC.writeSession = function (params) {
    callIOSFunction("BRC", "writeSession", params, null);
};

BRC.readSession = function (params,callBackName) {
    callIOSFunction("BRC", "readSession", params, callBackName);
};

BRC.removeSession = function (params) {
    callIOSFunction("BRC", "removeSession", params, null);
};

BRC.removeAllSession = function () {
    callIOSFunction("BRC", "removeAllSession", null, null);
};
//****************5.上导航 Title Bar*****************//
BRC.showTitleBar = function (params) {
    callIOSFunction("BRC", "showTitleBar", params, null);
};

BRC.setTitleBar = function (params) {
    callIOSFunction("BRC", "setTitleBar", params, null);
};

BRC.setLeftButton = function (params) {
    callIOSFunction("BRC", "setLeftButton", params, null);
};

BRC.setRightButton = function (params) {
    callIOSFunction("BRC", "setRightButton", params, null);
};

BRC.setRightButtonShare = function (params) {
    callIOSFunction("BRC", "setRightButtonShare", params, null);
};
//********************************************//

window["BRC"] = BRC;
