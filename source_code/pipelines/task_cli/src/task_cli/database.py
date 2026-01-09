"""Database operations for task management."""

import os
from typing import List, Optional
from datetime import datetime

from sqlalchemy import create_engine, and_
from sqlalchemy.orm import sessionmaker, Session

from .models import Base, Task, TaskCreate, TaskResponse, Priority


class TaskDatabase:
    def __init__(self, database_url: Optional[str] = None):
        if database_url is None:
            # Default to SQLite in user's home directory
            home_dir = os.path.expanduser("~")
            database_url = f"sqlite:///{home_dir}/.task_cli.db"

        self.engine = create_engine(database_url)
        Base.metadata.create_all(self.engine)
        self.SessionLocal = sessionmaker(bind=self.engine)

    def get_session(self) -> Session:
        return self.SessionLocal()

    def create_task(self, task_data: TaskCreate) -> TaskResponse:
        with self.get_session() as session:
            task = Task(
                title=task_data.title,
                description=task_data.description,
                priority=task_data.priority.value,
            )
            session.add(task)
            session.commit()
            session.refresh(task)
            return TaskResponse.from_orm(task)

    def list_tasks(
        self, completed: Optional[bool] = None, priority: Optional[Priority] = None
    ) -> List[TaskResponse]:
        with self.get_session() as session:
            query = session.query(Task)

            if completed is not None:
                query = query.filter(Task.completed == completed)

            if priority is not None:
                query = query.filter(Task.priority == priority.value)

            tasks = query.order_by(Task.created_at.desc()).all()
            return [TaskResponse.from_orm(task) for task in tasks]

    def complete_task(self, task_id: int) -> Optional[TaskResponse]:
        with self.get_session() as session:
            task = session.query(Task).filter(Task.id == task_id).first()
            if task:
                task.completed = True
                task.completed_at = datetime.utcnow()
                session.commit()
                session.refresh(task)
                return TaskResponse.from_orm(task)
            return None
