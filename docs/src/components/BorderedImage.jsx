import React from 'react';

const BorderedImage = ({ src, alt }) => {
  return (
    <div
      style={{
        border: '4px solid #ddd',
        padding: '4px',
        width: '300px',
      }}
    >
      <img src={src} alt={alt} />
    </div>
  );
};

export default BorderedImage;