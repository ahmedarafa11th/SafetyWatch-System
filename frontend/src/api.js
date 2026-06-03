const BASE_URL = '/api';

const request = async (endpoint, options = {}) => {
  const token = localStorage.getItem('sw_token');

  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...(options.headers || {}),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const config = {
    ...options,
    headers,
  };

  const response = await fetch(`${BASE_URL}${endpoint}`, config);

  // Try to parse JSON, fallback to text
  let data;
  try {
    data = await response.json();
  } catch (e) {
    data = { message: await response.text() };
  }

  if (!response.ok) {
    // Laravel returns { status: false, message: '...', errors: {} }
    throw {
      status: response.status,
      message: data.message || 'An error occurred',
      errors: data.errors || {},
      data,
    };
  }

  // Laravel ApiResponse trait wraps: { status: true, message: '...', data: {...} }
  // Return the full response so callers can access .data, .message, etc.
  return data;
};

export const api = {
  get:    (endpoint)        => request(endpoint, { method: 'GET' }),
  post:   (endpoint, body)  => request(endpoint, { method: 'POST',   body: JSON.stringify(body) }),
  put:    (endpoint, body)  => request(endpoint, { method: 'PUT',    body: JSON.stringify(body) }),
  patch:  (endpoint, body)  => request(endpoint, { method: 'PATCH',  body: JSON.stringify(body) }),
  delete: (endpoint)        => request(endpoint, { method: 'DELETE' }),
};
