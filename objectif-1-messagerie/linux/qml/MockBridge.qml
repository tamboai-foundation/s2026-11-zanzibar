pragma Singleton
import QtQuick

// Mock du pont UI <-> TModeler (compte + messagerie).
// Remplacer par un pont adossé à TModeler en gardant les mêmes propriétés et fonctions.
QtObject {
    id: bridge

    // --- Compte ---
    property var user: null          // { id, name } ou null
    function restoreSession() { return user }
    function login(identifier, password) {
        user = { id: 1, name: identifier.trim() || "Moi", bio: "", joinedAt: Date.now() }
        return user
    }
    function register(name, identifier, password) {
        user = { id: 1, name: name.trim() || "Moi", bio: "", joinedAt: Date.now() }
        return user
    }
    function logout() { user = null }

    // --- Messagerie ---
    readonly property int me: 1
    property int nextId: 100
    property var conversations: [
        { id: 1, title: "Awa Traoré", unread: 2, pinned: true, muted: false, archived: false },
        { id: 2, title: "Équipe NGoma", unread: 0, pinned: false, muted: false, archived: false },
        { id: 3, title: "Kofi Mensah", unread: 1, pinned: false, muted: false, archived: false },
        { id: 4, title: "Fatou Diop", unread: 0, pinned: false, muted: true, archived: false }
    ]
    property var messages: {
        var now = Date.now()
        return [
            { id: 1, conversationId: 1, authorId: 2, text: "Salut ! Tu as vu le nouveau projet ?", time: now - 3600000, reactions: {} },
            { id: 2, conversationId: 1, authorId: 2, text: "On commence demain matin.", time: now - 3500000, reactions: {} },
            { id: 3, conversationId: 2, authorId: 3, text: "Bienvenue dans l'équipe NGoma.", time: now - 86400000, reactions: {} },
            { id: 4, conversationId: 2, authorId: 1, text: "Merci, content d'être là !", time: now - 86000000, reactions: {} },
            { id: 5, conversationId: 3, authorId: 4, text: "Tu peux m'envoyer le rapport ?", time: now - 7200000, reactions: {} },
            { id: 6, conversationId: 4, authorId: 5, text: "Bonne journée à tous.", time: now - 172800000, reactions: {} }
        ]
    }

    function messagesOf(conversationId) {
        return messages.filter(function (m) { return m.conversationId === conversationId })
    }
    function lastMessage(conversationId) {
        var list = messagesOf(conversationId).filter(function (m) { return !m.deleted })
        return list.length ? list[list.length - 1] : null
    }

    function _patchMessage(id, f) {
        messages = messages.map(function (m) { return m.id === id ? f(m) : m })
    }
    function _patchConv(id, f) {
        conversations = conversations.map(function (c) { return c.id === id ? f(c) : c })
    }
    function _add(conversationId, authorId, text, replyToId) {
        messages = messages.concat([{
            id: nextId++, conversationId: conversationId, authorId: authorId,
            text: text, time: Date.now(), replyToId: replyToId || 0, reactions: {}
        }])
    }

    property var _pendingReplies: []
    function send(conversationId, text, replyToId) {
        _add(conversationId, me, text, replyToId)
        _pendingReplies = _pendingReplies.concat([conversationId])
        peerTimer.restart()
    }
    function edit(id, text) {
        _patchMessage(id, function (m) { var n = Object.assign({}, m); n.text = text; n.edited = true; return n })
    }
    function remove(id) {
        _patchMessage(id, function (m) { var n = Object.assign({}, m); n.text = ""; n.deleted = true; return n })
    }
    function react(id, emoji) {
        _patchMessage(id, function (m) {
            var n = Object.assign({}, m)
            n.reactions = Object.assign({}, m.reactions)
            n.reactions[emoji] = (n.reactions[emoji] || 0) + 1
            return n
        })
    }
    function markRead(id) {
        _patchConv(id, function (c) { return Object.assign({}, c, { unread: 0 }) })
    }
    function setPinned(id, v) { _patchConv(id, function (c) { return Object.assign({}, c, { pinned: v }) }) }
    function setMuted(id, v) { _patchConv(id, function (c) { return Object.assign({}, c, { muted: v }) }) }
    function setArchived(id, v) { _patchConv(id, function (c) { return Object.assign({}, c, { archived: v }) }) }
    function createConversation(title) {
        var id = 1
        conversations.forEach(function (c) { id = Math.max(id, c.id + 1) })
        conversations = conversations.concat([{ id: id, title: title, unread: 0, pinned: false, muted: false, archived: false }])
        return id
    }

    // --- Gestion des utilisateurs (M1 SI, module 1) ---
    readonly property var others: {
        var now = Date.now()
        return [
            { id: 2, name: "Awa Traoré", bio: "Développeuse mobile, Bamako.", joinedAt: now - 30 * 86400000 },
            { id: 3, name: "Kofi Mensah", bio: "Design et vidéo, Accra.", joinedAt: now - 20 * 86400000 },
            { id: 4, name: "Fatou Diop", bio: "Étudiante en informatique, Dakar.", joinedAt: now - 12 * 86400000 },
            { id: 5, name: "Moussa Keita", bio: "Cybersécurité.", joinedAt: now - 5 * 86400000 },
            { id: 6, name: "Aïcha Bello", bio: "Passionnée de musique et de code.", joinedAt: now - 2 * 86400000 }
        ]
    }
    // Tous les utilisateurs (moi en premier), filtrés par la recherche (nom ou description)
    function users(query) {
        var all = (user ? [user] : []).concat(others)
        var q = (query || "").toLowerCase()
        return all.filter(function (u) {
            return !q || u.name.toLowerCase().indexOf(q) >= 0 || (u.bio || "").toLowerCase().indexOf(q) >= 0
        })
    }
    function userById(id) {
        var all = (user ? [user] : []).concat(others)
        for (var i = 0; i < all.length; i++) if (all[i].id === id) return all[i]
        return null
    }
    function timeAgo(t) {
        var s = Math.max(1, Math.round((Date.now() - t) / 1000))
        if (s < 60) return "à l'instant"
        if (s < 3600) return "il y a " + Math.round(s / 60) + " min"
        if (s < 86400) return "il y a " + Math.round(s / 3600) + " h"
        return "il y a " + Math.round(s / 86400) + " j"
    }
    function authorName(id) { var u = userById(id); return u ? u.name : "Utilisateur" }
    function updateProfile(name, bio) {
        if (!user) return
        user = Object.assign({}, user, { name: name.trim() || user.name, bio: bio.trim() })
    }
    function deleteAccount() { logout() }

    // --- Publications vidéo (M1 SI, module 3) ---
    // mediaPath (photo ou vidéo) est facultatif : vide, la légende seule est affichée sur une carte colorée.
    property var posts: {
        var now = Date.now()
        return [
            { id: 1001, authorId: 2, caption: "Ma première application de messagerie, étape par étape ✨", mediaPath: "", time: now - 3600000, edited: false, likes: [3, 4, 5] },
            { id: 1002, authorId: 3, caption: "Un petit tour dans les coulisses de notre équipe 🎬", mediaPath: "", time: now - 7200000, edited: false, likes: [2] },
            { id: 1003, authorId: 4, caption: "Astuce du jour : tester chaque écran avant de le montrer.", mediaPath: "", time: now - 20000000, edited: false, likes: [2, 3, 5, 6] },
            { id: 1004, authorId: 5, caption: "Pourquoi on chiffre les messages ? Explication en 30 secondes.", mediaPath: "", time: now - 90000000, edited: false, likes: [] },
            { id: 1005, authorId: 6, caption: "Bienvenue sur NGoma 👋", mediaPath: "", time: now - 180000000, edited: false, likes: [2, 3] }
        ]
    }
    property var comments: {
        var now = Date.now()
        return [
            { id: 2001, postId: 1001, authorId: 3, text: "Bravo, très clair !", time: now - 3000000, parentId: 0, edited: false, deleted: false, likes: [] },
            { id: 2002, postId: 1001, authorId: 4, text: "Merci pour le partage 🙏", time: now - 2800000, parentId: 0, edited: false, deleted: false, likes: [] },
            { id: 2003, postId: 1001, authorId: 2, text: "Merci Kofi !", time: now - 2500000, parentId: 2001, edited: false, deleted: false, likes: [] }
        ]
    }
    property int nextPostId: 3000

    function feed() { return posts.slice().sort(function (a, b) { return b.time - a.time }) }
    function userPosts(userId) { return feed().filter(function (p) { return p.authorId === userId }) }
    function publish(caption, mediaPath) {
        posts = posts.concat([{ id: nextPostId++, authorId: me, caption: caption.trim(), mediaPath: mediaPath || "", time: Date.now(), edited: false, likes: [] }])
    }
    function _patchPost(id, f) { posts = posts.map(function (p) { return p.id === id ? f(p) : p }) }
    function editPost(id, caption) {
        _patchPost(id, function (p) { return Object.assign({}, p, { caption: caption.trim(), edited: true }) })
    }
    function removePost(id) {
        posts = posts.filter(function (p) { return p.id !== id })
        comments = comments.filter(function (c) { return c.postId !== id })
    }
    function _toggle(list, id) {
        return list.indexOf(id) >= 0 ? list.filter(function (x) { return x !== id }) : list.concat([id])
    }
    // Aime ou n'aime plus (bascule) pour l'utilisateur connecté
    function toggleLike(id) { _patchPost(id, function (p) { return Object.assign({}, p, { likes: _toggle(p.likes, me) }) }) }

    function commentsOf(postId) {
        return comments.filter(function (c) { return c.postId === postId }).sort(function (a, b) { return a.time - b.time })
    }
    function commentCount(postId) {
        return comments.filter(function (c) { return c.postId === postId && !c.deleted }).length
    }
    function addComment(postId, text, parentId) {
        comments = comments.concat([{ id: nextPostId++, postId: postId, authorId: me, text: text.trim(), time: Date.now(),
                                      parentId: parentId || 0, edited: false, deleted: false, likes: [] }])
    }
    function _patchComment(id, f) { comments = comments.map(function (c) { return c.id === id ? f(c) : c }) }
    function editComment(id, text) { _patchComment(id, function (c) { return Object.assign({}, c, { text: text.trim(), edited: true }) }) }
    function removeComment(id) { _patchComment(id, function (c) { return Object.assign({}, c, { text: "", deleted: true }) }) }
    function toggleCommentLike(id) { _patchComment(id, function (c) { return Object.assign({}, c, { likes: _toggle(c.likes, me) }) }) }

    // Réponse simulée d'un interlocuteur
    property Timer peerTimer: Timer {
        interval: 1500
        onTriggered: {
            var ids = bridge._pendingReplies
            bridge._pendingReplies = []
            ids.forEach(function (cid) {
                bridge._add(cid, 2, "Bien reçu 👍", 0)
                bridge._patchConv(cid, function (c) { return Object.assign({}, c, { unread: c.unread + 1 }) })
            })
        }
    }
}
