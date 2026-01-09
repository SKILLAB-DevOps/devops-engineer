"""Test database operations."""

import pytest
from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from task_cli.database import TaskDatabase
from task_cli.models import Base, TaskCreate, Priority


@pytest.fixture
def test_db():
    """Create a test database in memory."""
    db = TaskDatabase("sqlite:///:memory:")
    return db


def test_create_task(test_db):
    """Test task creation."""
    task_data = TaskCreate(
        title="Test Task", description="Test Description", priority=Priority.HIGH
    )

    task = test_db.create_task(task_data)

    assert task.title == "Test Task"
    assert task.description == "Test Description"
    assert task.priority == Priority.HIGH
    assert task.completed is False
    assert task.id is not None


def test_list_tasks(test_db):
    """Test task listing with filters."""
    # Create test tasks
    high_task = TaskCreate(title="Urgent Task", priority=Priority.HIGH)
    low_task = TaskCreate(title="Later Task", priority=Priority.LOW)

    test_db.create_task(high_task)
    test_db.create_task(low_task)

    # Test listing all tasks
    all_tasks = test_db.list_tasks()
    assert len(all_tasks) == 2

    # Test filtering by priority
    high_tasks = test_db.list_tasks(priority=Priority.HIGH)
    assert len(high_tasks) == 1
    assert high_tasks[0].title == "Urgent Task"


def test_complete_task(test_db):
    """Test task completion."""
    task_data = TaskCreate(title="Complete Me")
    task = test_db.create_task(task_data)

    # Complete the task
    completed_task = test_db.complete_task(task.id)

    assert completed_task is not None
    assert completed_task.completed is True
    assert completed_task.completed_at is not None
