import { ApiResponse } from "../utils/ApiResponse.js";

export const successHandler = (
    res,
    statusCode,
    message,
    data = null
) => {

    return res.status(statusCode).json(

        new ApiResponse(
            true,
            statusCode,
            message,
            data
        )

    );

};