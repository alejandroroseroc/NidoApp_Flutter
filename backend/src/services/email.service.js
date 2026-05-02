const nodemailer = require('nodemailer');

// Configura el transporte SMTP con Gmail.
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const emailService = {
  async sendPasswordResetCode(correo, codigo) {
    const mailOptions = {
      from: `"NidoApp" <${process.env.EMAIL_USER}>`,
      to: correo,
      subject: 'Recupera tu contraseña — NidoApp',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
          <h2 style="color: #2D7D6F;">Recupera tu contraseña</h2>
          <p>Usa el siguiente código para restablecer tu contraseña. Expira en <strong>15 minutos</strong>.</p>
          <div style="
            font-size: 36px;
            font-weight: bold;
            letter-spacing: 10px;
            color: #2D7D6F;
            background: #F5FFFE;
            border: 2px solid #2D7D6F;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 24px 0;
          ">
            ${codigo}
          </div>
          <p style="color: #4A6B68; font-size: 14px;">
            Si no solicitaste este código, ignora este correo.
          </p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
  },
};

module.exports = emailService;
