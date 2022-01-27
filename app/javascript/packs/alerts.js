// packs/notices.js
function checkNotices() {
    for (i = 0; i < document.getElementsByClassName('notice-float').length; i++) {
        if (document.getElementsByClassName('notice-float')[i].style.display != 'none') {
            hideNotice(i);
        }
    }
}

function hideNotice(i) {
    setTimeout(function() {
        if (!!document.getElementsByClassName('notice-float')[i]) {
            document.getElementsByClassName('notice-float')[i].style.display = 'none';
        }
    }, 2400);
}

checkNotices();
setInterval(function() {
    checkNotices();
}, 2400);

window.createNotice = createNotice;

function createNotice(message) {
    let notice = document.createElement("p");
    let messageContent = document.createTextNode(message);
    notice.className = "notice-float";
    notice.appendChild(messageContent);
    document.body.appendChild(notice);
}