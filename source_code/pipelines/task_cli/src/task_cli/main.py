"""Task Management CLI - A production-ready example."""

from datetime import datetime
from typing import Optional

import typer
from rich import print
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

from .database import TaskDatabase
from .models import TaskCreate, Priority

# Initialize the Typer app and database
app = typer.Typer(help="🚀 Modern Task Management CLI")
console = Console()
db = TaskDatabase()


@app.command()
def add(
    title: str = typer.Argument(..., help="Task title"),
    description: Optional[str] = typer.Option(
        None, "--desc", "-d", help="Task description"
    ),
    priority: Priority = typer.Option(
        Priority.MEDIUM, "--priority", "-p", help="Task priority"
    ),
):
    """Add a new task to your list."""
    task_data = TaskCreate(title=title, description=description, priority=priority)
    task = db.create_task(task_data)

    print(f"✅ Task created with ID: [bold green]{task.id}[/bold green]")
    print(f"📝 Title: {task.title}")
    if task.description:
        print(f"📄 Description: {task.description}")
    print(f"⚡ Priority: {task.priority}")


@app.command()
def list(
    all: bool = typer.Option(False, "--all", "-a", help="Show completed tasks too"),
    priority: Optional[Priority] = typer.Option(
        None, "--priority", "-p", help="Filter by priority"
    ),
):
    """List your tasks."""
    tasks = db.list_tasks(completed=None if all else False, priority=priority)

    if not tasks:
        print("📭 No tasks found. Add some with 'task add'!")
        return

    table = Table(title="📋 Your Tasks")
    table.add_column("ID", style="cyan", no_wrap=True)
    table.add_column("Title", style="magenta")
    table.add_column("Priority", style="yellow")
    table.add_column("Status", style="green")
    table.add_column("Created", style="blue")

    for task in tasks:
        status = "✅ Done" if task.completed else "⏳ Pending"
        priority_emoji = {"low": "🟢", "medium": "🟡", "high": "🟠", "urgent": "🔴"}
        priority_display = f"{priority_emoji.get(task.priority, '⚪')} {task.priority}"

        table.add_row(
            str(task.id),
            task.title,
            priority_display,
            status,
            task.created_at.strftime("%Y-%m-%d %H:%M"),
        )

    console.print(table)


@app.command()
def complete(task_id: int = typer.Argument(..., help="Task ID to complete")):
    """Mark a task as completed."""
    task = db.complete_task(task_id)

    if task:
        print(f"🎉 Task '{task.title}' marked as completed!")
    else:
        print(f"❌ Task with ID {task_id} not found.")
        raise typer.Exit(1)


@app.command()
def stats():
    """Show task statistics."""
    all_tasks = db.list_tasks()
    completed_tasks = db.list_tasks(completed=True)
    pending_tasks = db.list_tasks(completed=False)

    completion_rate = len(completed_tasks) / len(all_tasks) * 100 if all_tasks else 0

    stats_panel = Panel.fit(
        f"""
📊 Task Statistics

Total Tasks: {len(all_tasks)}
✅ Completed: {len(completed_tasks)}
⏳ Pending: {len(pending_tasks)}
📈 Completion Rate: {completion_rate:.1f}%
        """,
        title="Dashboard",
        border_style="green",
    )

    console.print(stats_panel)


if __name__ == "__main__":
    app()
