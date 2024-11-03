const express = require('express')
const http = require('http')
const { Server } = require('socket.io')
const crypto = require('crypto')
const app = express()
const server = http.createServer(app)

const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST']
    }
})

const webClients = {}

function generateUuid(bytes) {
    return crypto.randomBytes(bytes).toString('hex')
}

io.on('connection', (socket) => {
    console.log(`Bir kullanıcı bağlandı: ${socket.id}`)
    let uuid = generateUuid(10)

    socket.on('login', () => {
        webClients[uuid] = { socket: socket, player1: null, player2: null }
        socket.emit('uuid', uuid)
        console.log('Login başarılı. Toplam bağlı webClient:', Object.keys(webClients).length)
    })

    socket.on('uuid', (data) => {
        console.log('UUID ile eşleştirme isteği:', data)
        const targetClient = webClients[data]
        if (targetClient) {
            if (targetClient.player1 == null) {
                targetClient.player1 = socket
                uuid = data
                targetClient.socket.emit('player1', { connected: true })
                socket.emit('uuid', { connected: true })
                console.log(`Player1 Bağlandı: ${data}`)
            } else if (targetClient.player2 == null) {
                targetClient.player2 = socket
                uuid = data
                targetClient.socket.emit('player2', { connected: true })
                socket.emit('uuid', { connected: true })
                console.log(`Player2 Bağlandı: ${data}`)
            } else {
                socket.emit('error', `Bu UUID için zaten 2 oyuncu bağlı: ${data}`)
                console.log(`Bu UUID için zaten 2 oyuncu bağlı: ${data}`)
            }
        } else {
            console.log('Hedef UUID bulunamadı:', data)
            socket.emit('uuid', { connected: false })
        }
    })

    socket.on('playerData', (message) => {
        const targetClient = webClients[uuid]

        if (targetClient) {
            if (targetClient.player1 != null && targetClient.player1.id === socket.id) {
                targetClient.socket.emit('player1', message)
            } else
                if (targetClient.player1 != null && targetClient.player2.id === socket.id) {
                    targetClient.socket.emit('player2', message)
                }
        } else {
            console.log(`UUID ${uuid} bulunamadı, veri iletilemedi.`)
        }
    })

    socket.on('disconnect', () => {
        const clientData = webClients[uuid]
        if (!clientData) {
            console.log('UUID bulunamadı. Bağlantı koparıldı:', socket.id)
            return
        }

        if (clientData.socket.id === socket.id) {
            console.log(`UUID ${uuid} bağlantıyı kapattı. UUID silindi.`)
            if (clientData.player1) clientData.player1.emit('uuid', { connected: false })
            if (clientData.player2) clientData.player2.emit('uuid', { connected: false })
            delete webClients[uuid]
            return
        }
        if (clientData) {
            if (clientData.player1 === socket) {
                clientData.socket.emit('player1', { connected: false })
                clientData.socket.emit('player2', { connected: false })
                clientData.player1 = null
                clientData.player2 = null
                console.log(`Player1 UUID ${uuid} bağlantıyı kapattı. Player1 ve Player2 null yapıldı.`)
            }
            else if (clientData.player2 === socket) {
                clientData.player2 = null
                clientData.socket.emit('player2', { connected: false })
                console.log(`Player2 UUID ${uuid} bağlantıyı kapattı. Sadece Player2 null yapıldı.`)
            }
        }
    })
})

const PORT = 3000
server.listen(PORT, () => {
    console.log(`Sunucu ${PORT} portunda çalışıyor`)
})
