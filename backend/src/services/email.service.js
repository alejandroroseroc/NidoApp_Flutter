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
  async sendReservaStatusUpdate({ correoInvitado, nombreInvitado, tituloAlojamiento, ubicacion, fechaIngreso, duracionDias, nuevoEstado }) {
    const aceptada = nuevoEstado === 'ACEPTADA';

    const estadoColor  = aceptada ? '#2D7D6F' : '#C0392B';
    const estadoBg     = aceptada ? '#F5FFFE' : '#FFF5F5';
    const estadoTexto  = aceptada ? '✓ Reserva Aceptada' : '✗ Reserva No Aceptada';
    const mensajePrincipal = aceptada
      ? `¡Buenas noticias! El anfitrión ha <strong>aceptado</strong> tu solicitud de reserva. Pronto podrás coordinar los detalles de tu llegada.`
      : `Lamentablemente el anfitrión ha <strong>rechazado</strong> tu solicitud de reserva en esta ocasión. Te invitamos a explorar otros alojamientos disponibles en NidoApp.`;

    const fecha = new Date(fechaIngreso).toLocaleDateString('es-CO', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });

    const mailOptions = {
      from: `"NidoApp" <${process.env.EMAIL_USER}>`,
      to: correoInvitado,
      subject: `Tu reserva fue ${aceptada ? 'aceptada' : 'rechazada'} — NidoApp`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 520px; margin: 0 auto; color: #1A2E2B;">

          <div style="background: #2D7D6F; padding: 24px 32px; border-radius: 12px 12px 0 0;">
            <h1 style="color: #fff; margin: 0; font-size: 22px;">NidoApp</h1>
            <p style="color: #B2DDD8; margin: 4px 0 0; font-size: 14px;">Actualización de tu solicitud de reserva</p>
          </div>

          <div style="background: #fff; padding: 28px 32px; border: 1px solid #E0EEEC; border-top: none;">

            <p style="font-size: 16px; margin-top: 0;">Hola, <strong>${nombreInvitado}</strong>.</p>
            <p style="font-size: 15px; line-height: 1.6;">${mensajePrincipal}</p>

            <!-- Badge de estado -->
            <div style="
              display: inline-block;
              background: ${estadoBg};
              border: 2px solid ${estadoColor};
              border-radius: 8px;
              padding: 10px 24px;
              font-size: 18px;
              font-weight: bold;
              color: ${estadoColor};
              margin: 8px 0 24px;
            ">${estadoTexto}</div>

            <!-- Detalles de la reserva -->
            <div style="background: #F5FFFE; border-radius: 10px; padding: 20px 24px; margin-bottom: 24px;">
              <h3 style="margin: 0 0 14px; color: #2D7D6F; font-size: 15px; text-transform: uppercase; letter-spacing: 0.5px;">Detalles de la reserva</h3>

              <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                <tr>
                  <td style="padding: 6px 0; color: #4A6B68; width: 140px;">Alojamiento</td>
                  <td style="padding: 6px 0; font-weight: 600;">${tituloAlojamiento}</td>
                </tr>
                <tr>
                  <td style="padding: 6px 0; color: #4A6B68;">Ubicación</td>
                  <td style="padding: 6px 0;">${ubicacion}</td>
                </tr>
                <tr>
                  <td style="padding: 6px 0; color: #4A6B68;">Fecha de ingreso</td>
                  <td style="padding: 6px 0;">${fecha}</td>
                </tr>
                <tr>
                  <td style="padding: 6px 0; color: #4A6B68;">Duración</td>
                  <td style="padding: 6px 0;">${duracionDias} ${duracionDias === 1 ? 'día' : 'días'}</td>
                </tr>
              </table>
            </div>

            <p style="color: #4A6B68; font-size: 13px; margin-bottom: 0;">
              Si tienes alguna pregunta, abre la app y revisa el estado de tu reserva en la sección <strong>Mis Reservas</strong>.
            </p>
          </div>

          <div style="background: #F0F8F7; padding: 16px 32px; border-radius: 0 0 12px 12px; text-align: center;">
            <p style="color: #7A9E9B; font-size: 12px; margin: 0;">© NidoApp — Este correo fue enviado automáticamente, por favor no respondas.</p>
          </div>

        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
  },

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
