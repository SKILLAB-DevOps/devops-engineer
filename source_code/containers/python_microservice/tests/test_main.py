from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hell on World"}


def test_get_version():
    response = client.get("/version")
    assert response.status_code == 200
    assert response.json() == {"version": "0.0.1"}


def test_read_data():
    response = client.get("/data/ion")
    assert response.status_code == 200
    assert response.json() == {"message": "Hell on World ion"}


def test_invalidate_read_data():
    response = client.get("/data/ion")
    assert response.status_code == 200
    assert response.json() != {"message": "Hell on World vasile"}


def test_read_healthcheck():
    response = client.get("/healthcheck")
    assert response.status_code == 200
    assert response.json() == {"status": "ready", "status_code": 200}
