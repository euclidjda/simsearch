/**
 * Normal Application Utility (NAU) methods.
 * 
 * The idea is that these are all totally generic, ready
 * to be open-sourced.
 */
var NAU = NAU || {};

NAU.alert = function(msg) {
    window.alert(msg);
}

NAU.log = (function() {
    if(typeof console=="undefined" ) {
        // If browser doesn't support it, do nothing.
        return function() {};
    } else {
        return function() {
            console.log.apply(console,arguments);  // just passes args to console.log
        }
    }
})();

NAU.navigate = function(url) {
    // pre-navigation code will go here...
    window.location.href = url;
}


/*
 * NAU.q handles the common JS initialization pattern of needing something to 
 * run after another object is done initializing, which is signaled by a callback,
 * but that callback might fire before your code even queues up the initializer.
 *
 * For example with facebook, you queue up your init code with
 *     NAU.q.on("facebook-init",function() {...});
 * and then in the FB init callback you clear the queue
 *     window.fbAsyncInit = NAU.q.fireClosure("facebook-init");
 * Your init code will fire regardless of whether it gets queued before or
 * after the facebook init event happens.
 */
NAU.q = (function() {
    var queues = {};
    var firedYet = {};
    var q = {};
    q.on = function(eventName, func) {
        if( firedYet[eventName] ) {
            func();
        } else {
            queues[eventName] = queues[eventName] || [];
            queues[eventName].push(func);
        }
    }

    q.fire = function(eventName) {
        firedYet[eventName] = true;
        _.each(queues[eventName],function(fn) {
            fn();
        });
    };

    q.fireClosure = function(eventName) {
        return function() {
            q.fire(eventName);
        };
    };

    return q;
})();
