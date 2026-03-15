const request = require('supertest');
const app = require('../index');

let server;

beforeAll(() => {
  server = app.listen(0);
});

afterAll((done) => {
  server.close(done);
});

describe('Weather App', () => {
  test('GET /health returns 200', async () => {
    const res = await request(server).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
  });

  test('GET /weather without city returns 400', async () => {
    const res = await request(server).get('/weather');
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toBe('City is required');
  });
});