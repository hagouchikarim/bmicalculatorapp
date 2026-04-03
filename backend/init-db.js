const mysql = require('mysql2/promise');
require('dotenv').config();

async function initDb() {
    try {
        // Connexion sans spécifier de base de données
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASS || '',
            port: process.env.DB_PORT || 3306
        });

        const dbName = process.env.DB_NAME || 'bmi_db';
        await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
        console.log(`✅ Base de données '${dbName}' créée ou déjà existante.`);
        process.exit(0);
    } catch (error) {
        console.error("❌ Erreur lors de la création de la base de données :", error);
        process.exit(1);
    }
}

initDb();
