const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const sequelize = require('./config/database');
const User = require('./models/User');

const app = express();
const PORT = process.env.PORT || 3000;
const SECRET_KEY = process.env.SECRET_KEY || "votre_cle_secrete_super_puissante";

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Connexion et Synchronisation de la Base de Données
sequelize.sync({ alter: true }) // 'alter: true' met à jour les tables si le modèle change
    .then(async () => {
        console.log("✅ MySQL Connecté et synchronisé avec Sequelize");
        
        // Créer l'admin par défaut s'il n'existe pas
        const adminExists = await User.findOne({ where: { username: "admin@test.com" } });
        if (!adminExists) {
            await User.create({
                username: "admin@test.com",
                password: bcrypt.hashSync("1234", 10),
                name: "Administrator",
                gender: "M"
            });
            console.log("🚀 Utilisateur admin par défaut créé.");
        }
    })
    .catch(err => console.error("❌ Erreur de connexion MySQL :", err));

// MIDDLEWARE : Vérification de l'authentification Basic (Client ID & Secret)
const verifyBasicAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Basic ')) {
        return res.status(401).json({ error: "Missing Basic Authentication" });
    }

    const base64Credentials = authHeader.split(' ')[1];
    const credentials = Buffer.from(base64Credentials, 'base64').toString('ascii');
    const [clientId, clientSecret] = credentials.split(':');

    if (clientId === 'express-client' && clientSecret === 'express-secret') {
        next();
    } else {
        res.status(401).json({ error: "Invalid Client Credentials" });
    }
};

// ROUTE : Login / OAuth2 Token
app.post('/oauth/token', verifyBasicAuth, async (req, res) => {
    const { username, password, grant_type, refresh_token } = req.body;

    if (grant_type === 'password') {
        try {
            const user = await User.findOne({ where: { username } });
            if (user && bcrypt.compareSync(password, user.password)) {
                const accessToken = jwt.sign(
                    { username: user.username, name: user.name, gender: user.gender }, 
                    SECRET_KEY, 
                    { expiresIn: '1h' }
                );
                const newRefreshToken = jwt.sign(
                    { username: user.username }, 
                    SECRET_KEY, 
                    { expiresIn: '7d' }
                );
                
                return res.json({
                    access_token: accessToken,
                    refresh_token: newRefreshToken,
                    token_type: "Bearer",
                    expires_in: 3600,
                    user: { name: user.name, gender: user.gender }
                });
            }
            return res.status(400).json({ error: "Invalid username or password" });
        } catch (err) {
            return res.status(500).json({ error: "Database error" });
        }
    } 
    
    if (grant_type === 'refresh_token') {
        if (!refresh_token) return res.status(400).json({ error: "Refresh token missing" });
        
        try {
            const decoded = jwt.verify(refresh_token, SECRET_KEY);
            const user = await User.findOne({ where: { username: decoded.username } });
            
            if (!user) return res.status(401).json({ error: "User not found" });

            const accessToken = jwt.sign(
                { username: user.username, name: user.name, gender: user.gender }, 
                SECRET_KEY, 
                { expiresIn: '1h' }
            );
            
            return res.json({
                access_token: accessToken,
                refresh_token: refresh_token,
                token_type: "Bearer"
            });
        } catch (err) {
            return res.status(401).json({ error: "Invalid refresh token" });
        }
    }

    res.status(400).json({ error: "Unsupported grant type" });
});

// ROUTE : Signup / Inscription
app.post('/oauth/signup', async (req, res) => {
    const { username, password, name, gender } = req.body;
    
    if (!username || !password) {
        return res.status(400).json({ error: "Username and password required" });
    }

    try {
        const existingUser = await User.findOne({ where: { username } });
        if (existingUser) {
            return res.status(400).json({ error: "User already exists" });
        }

        const hashedPassword = bcrypt.hashSync(password, 10);
        
        await User.create({ username, password: hashedPassword, name, gender });
        console.log(`🚀 Nouvel utilisateur enregistré dans MySQL : ${username}`);
        
        res.status(201).json({ message: "User created successfully" });
    } catch (err) {
        console.error("Signup error:", err);
        res.status(500).json({ error: "Database error" });
    }
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

// ROUTE : Profile Area
app.get('/api/profile', verifyToken, (req, res) => {
    res.json({ 
        message: "Profile data fetched successfully", 
        user: {
            username: req.user.username,
            name: req.user.name,
            gender: req.user.gender
        } 
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Serveur BMI-SYNC lancé sur http://localhost:${PORT}`);
    console.log(`🚀 Mode MySQL / Sequelize activé via XAMPP`);
});
