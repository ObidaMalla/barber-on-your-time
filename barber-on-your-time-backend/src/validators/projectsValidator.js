import { body } from "express-validator";
import { ApiError } from "../utils/ApiError.js";


export const createProjectValidator = [

    body("name")
        .trim()
        .notEmpty()
        .withMessage("Project name is required")
        .isLength({ min: 2, max: 100 })
        .withMessage(
            "Project name must be between 2 and 100 characters"
        ),

    body("description")
        .optional()
        .trim()
        .isLength({ max: 500 })
        .withMessage(
            "Description cannot exceed 500 characters"
        )

];

export const updateProjectValidator = [

    body("name")
        .optional()
        .trim()
        .notEmpty()
        .withMessage("Project name cannot be empty")
        .isLength({ min: 2, max: 100 })
        .withMessage(
            "Project name must be between 2 and 100 characters"
        ),

    body("description")
        .optional()
        .trim()
        .isLength({ max: 500 })
        .withMessage(
            "Description cannot exceed 500 characters"
        )

];