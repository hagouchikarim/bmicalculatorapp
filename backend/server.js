const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const PORT = 3000;
const SECRET_KEY = "votre_cle_secrete_super_puissante";

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Simulation d'une base de données d'utilisateurs
const users = [
    { username: "admin@test.com", password: "1234", name: "Administrator", gender: "M" }
];

// MIDDLEWARE : Vérification de l'authentification Basic (Client ID & Secret)
const verifyBasicAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Basic ')) {
        return res.status(401).json({ error: "Missing Basic Authentication" });
    }

    const base64Credentials = authHeader.split(' ')[1];
    const credentials = Buffer.from(base64Credentials, 'base64').toString('ascii');
    const [clientId, clientSecret] = credentials.split(':');

    // Identifiants configurés dans votre Flutter (Step #5)
    if (clientId === 'express-client' && clientSecret === 'express-secret') {
        next();
    } else {
        res.status(401).json({ error: "Invalid Client Credentials" });
    }
};

// ROUTE : Login / OAuth2 Token
app.post('/oauth/token', verifyBasicAuth, (req, res) => {
    const { username, password, grant_type, refresh_token } = req.body;

    if (grant_type === 'password') {
        const user = users.find(u => u.username === username && u.password === password);
        if (user) {
            const accessToken = jwt.sign({ username: user.username, name: user.name, gender: user.gender }, SECRET_KEY, { expiresIn: '1h' });
            const newRefreshToken = jwt.sign({ username: user.username }, SECRET_KEY, { expiresIn: '7d' });
            
            return res.json({
                access_token: accessToken,
                refresh_token: newRefreshToken,
                token_type: "Bearer",
                expires_in: 3600,
                user: { name: user.name, gender: user.gender }
            });
        }
        return res.status(400).json({ error: "Invalid username or password" });
    } 
    
    if (grant_type === 'refresh_token') {
        if (!refresh_token) return res.status(400).json({ error: "Refresh token missing" });
        
        try {
            const decoded = jwt.verify(refresh_token, SECRET_KEY);
            const accessToken = jwt.sign({ username: decoded.username }, SECRET_KEY, { expiresIn: '1h' });
            return res.json({
                access_token: accessToken,
                refresh_token: refresh_token, // On peut garder le même ou en générer un nouveau
                token_type: "Bearer"
            });
        } catch (err) {
            return res.status(401).json({ error: "Invalid refresh token" });
        }
    }

    res.status(400).json({ error: "Unsupported grant type" });
});

// ROUTE : Signup / Inscription
app.post('/oauth/signup', (req, res) => {
    const { username, password, name, gender } = req.body;
    if (users.find(u => u.username === username)) {
        return res.status(400).json({ error: "User already exists" });
    }
    users.push({ username, password, name, gender });
    console.log(`Nouvel utilisateur enregistré : ${username}`);
    res.status(201).json({ message: "User created successfully" });
});

// MIDDLEWARE : Vérification du Token JWT (Bearer)
const verifyToken = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: "Unauthorized access" });
    }

    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, SECRET_KEY);
        req.user = decoded;
        next();
    } catch (err) {
        res.status(401).json({ error: "Invalid or expired token" });
    }
};

// ROUTE : Secret Area (Optionnelle, demandée dans Step #4)
app.get('/secret', verifyToken, (req, res) => {
    res.json({ message: "Bienvenue dans la zone sécurisée !", user: req.user });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Serveur Backend "Puissant" lancé sur http://localhost:${PORT}`);
    console.log(`Attente de connexions de l'App Flutter...`);
});
