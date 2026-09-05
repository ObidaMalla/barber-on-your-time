import { body } from "express-validator";

export const createTaskValidator = [

    body("title")
        .trim()
        .notEmpty()
        .withMessage("Title is required")
        .isLength({ min: 2 })
        .withMessage(
            "Title must be at least 2 characters"
        ),

    body("description")
        .optional()
        .trim()

];
export const updateTaskValidator = [

    body("title")
        .optional()
        .trim()
        .isLength({ min: 2 })
        .withMessage(
            "Title must be at least 2 characters"
        ),

    body("description")
    .optional()
    .trim()
    .isString()
    .withMessage("Description must be a string"),

    body("status")
        .optional()
        .isIn([
            "TODO",
            "IN_PROGRESS",
            "DONE"
        ])
        .withMessage(
            "Invalid task status"
        )

];


export const paginationValidator = [

    body("page")
        .isInt({ min: 1 })
        .withMessage(
            "Page must be an integer greater than 0"
        ),

    body("pageSize")
        .isInt({ min: 1, max: 100 })
        .withMessage(
            "Page size must be between 1 and 100"
        )

];