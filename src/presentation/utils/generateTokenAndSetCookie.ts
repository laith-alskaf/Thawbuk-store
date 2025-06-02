// import jwt from "jsonwebtoken"
// export const generateTokenAndSetCookie = (userId:string) => {
//     const token = jwt.sign({ userId }, process.env.JWT_SECRET||"ds@#(HEuwhe12!&#&@^iej12y&@TG!Y", {
//         expiresIn: "7d",
//     });
//     res.cookie("token", token, {
//         httpOnly: true,
//         secure: process.env.NOOE_ENV === "production",
//         // sameSite: "scrict",
//         maxAge: 7 * 24 * 60 * 60 * 1000, //7d
//     });
//     return token;
// }