import express from "express";
import multer from "multer";
import path from "path";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(express.static("uploads"));
app.use(cors());

const storage = multer.diskStorage({
    destination: "uploads/",
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    },
});

const upload = multer({ storage });

app.get("/", (req, res) => {
    res.send(`
    <html lang="fr">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Upload d'image</title>
        </head>
        <body>
            <h2>Uploader une image</h2>
            <form method="POST" action="/submit" enctype="multipart/form-data">
                <input type="file" name="image" required>
                <button type="submit">Envoyer</button>
            </form>
        </body>
    </html>
  `);
});

app.post("/submit", upload.single("image"), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send("Aucun fichier envoyé.");
        }

        res.send("Image envoyée avec succès !");
    } catch (error) {
        console.error("Erreur lors de l'envoi du message:", error);
        res.status(500).send(
            "Erreur lors de l'envoi du message: " + error.message,
        );
    }
});

const port = process.env.PORT || 8000;
app.listen(port, () => {
    console.log(`Application web démarrée sur le port ${port}`);
});
