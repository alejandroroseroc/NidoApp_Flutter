const { Resend } = require('resend');

const FROM = process.env.RESEND_FROM || 'NidoApp <onboarding@resend.dev>';

function getResendClient() {
  if (!process.env.RESEND_API_KEY) {
    const error = new Error('No se configuro RESEND_API_KEY para enviar correos');
    error.statusCode = 500;
    throw error;
  }

  return new Resend(process.env.RESEND_API_KEY);
}

async function sendEmail(payload) {
  const resend = getResendClient();
  const result = await resend.emails.send({
    from: FROM,
    ...payload,
  });

  if (result?.error) {
    console.error('[email] Resend rechazo el envio:', result.error);
    const error = new Error(
      result.error.message ||
        'No se pudo enviar el correo. Verifica el remitente configurado en Resend.',
    );
    error.statusCode = 502;
    throw error;
  }

  return result?.data;
}

const emailService = {
  async sendReservaStatusUpdate({
    correoInvitado,
    nombreInvitado,
    tituloAlojamiento,
    ubicacion,
    fechaIngreso,
    duracionDias,
    nuevoEstado,
  }) {
    const aceptada = nuevoEstado === 'ACEPTADA';
    const estadoColor = aceptada ? '#2D7D6F' : '#C0392B';
    const estadoBg = aceptada ? '#F5FFFE' : '#FFF5F5';
    const estadoTexto = aceptada ? 'Reserva aceptada' : 'Reserva no aceptada';
    const mensajePrincipal = aceptada
      ? 'Buenas noticias. El anfitrion ha <strong>aceptado</strong> tu solicitud de reserva.'
      : 'El anfitrion ha <strong>rechazado</strong> tu solicitud de reserva.';

    const fecha = new Date(fechaIngreso).toLocaleDateString('es-CO', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });

    return sendEmail({
      to: correoInvitado,
      subject: `Tu reserva fue ${aceptada ? 'aceptada' : 'rechazada'} - NidoApp`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 520px; margin: 0 auto; color: #1A2E2B;">
          <div style="background: #2D7D6F; padding: 24px 32px; border-radius: 12px 12px 0 0;">
            <h1 style="color: #fff; margin: 0; font-size: 22px;">NidoApp</h1>
            <p style="color: #B2DDD8; margin: 4px 0 0; font-size: 14px;">Actualizacion de tu solicitud de reserva</p>
          </div>
          <div style="background: #fff; padding: 28px 32px; border: 1px solid #E0EEEC; border-top: none;">
            <p style="font-size: 16px; margin-top: 0;">Hola, <strong>${nombreInvitado}</strong>.</p>
            <p style="font-size: 15px; line-height: 1.6;">${mensajePrincipal}</p>
            <div style="display: inline-block; background: ${estadoBg}; border: 2px solid ${estadoColor}; border-radius: 8px; padding: 10px 24px; font-size: 18px; font-weight: bold; color: ${estadoColor}; margin: 8px 0 24px;">${estadoTexto}</div>
            <div style="background: #F5FFFE; border-radius: 10px; padding: 20px 24px; margin-bottom: 24px;">
              <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                <tr><td style="padding: 6px 0; color: #4A6B68; width: 140px;">Alojamiento</td><td style="padding: 6px 0; font-weight: 600;">${tituloAlojamiento}</td></tr>
                <tr><td style="padding: 6px 0; color: #4A6B68;">Ubicacion</td><td style="padding: 6px 0;">${ubicacion}</td></tr>
                <tr><td style="padding: 6px 0; color: #4A6B68;">Fecha de ingreso</td><td style="padding: 6px 0;">${fecha}</td></tr>
                <tr><td style="padding: 6px 0; color: #4A6B68;">Duracion</td><td style="padding: 6px 0;">${duracionDias} ${duracionDias === 1 ? 'dia' : 'dias'}</td></tr>
              </table>
            </div>
          </div>
          <div style="background: #F0F8F7; padding: 16px 32px; border-radius: 0 0 12px 12px; text-align: center;">
            <p style="color: #7A9E9B; font-size: 12px; margin: 0;">NidoApp - Este correo fue enviado automaticamente.</p>
          </div>
        </div>
      `,
    });
  },

  async sendPasswordResetCode(correo, codigo) {
    return sendEmail({
      to: correo,
      subject: 'Recupera tu contrasena - NidoApp',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
          <h2 style="color: #2D7D6F;">Recupera tu contrasena</h2>
          <p>Usa el siguiente codigo para restablecer tu contrasena. Expira en <strong>15 minutos</strong>.</p>
          <div style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #2D7D6F; background: #F5FFFE; border: 2px solid #2D7D6F; border-radius: 8px; padding: 20px; text-align: center; margin: 24px 0;">
            ${codigo}
          </div>
          <p style="color: #4A6B68; font-size: 14px;">Si no solicitaste este codigo, ignora este correo.</p>
        </div>
      `,
    });
  },
};

module.exports = emailService;
