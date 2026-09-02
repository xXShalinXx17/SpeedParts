import React from 'react';
import { Link } from 'react-router-dom';

function InicioSesion() {
  return (
    <div>
      <h1>Iniciar Sesión</h1>
      <Link to="/">Volver a Inicio</Link>
    </div>
  );
}

export default InicioSesion;