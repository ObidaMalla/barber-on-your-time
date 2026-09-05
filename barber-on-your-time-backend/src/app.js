import express from "express";
import dotenv from "dotenv";
import router from "./routes/index.js";
import { errorHandler } from "./handlers/errorHandler.js";

dotenv.config();

const app = express();

app.use(express.json());
app.use("/", router);

app.use(errorHandler);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log("تم الرفع على github");
  
});