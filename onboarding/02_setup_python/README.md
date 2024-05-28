# Python installation

## Old setup (Poetry)

- Install Python via `Homebrew` on your machine.
- Specify dependencies in `pyproject.toml` file.
- Install `Poetry` for managing virtual environments, installing the project, and creating build files.

## New setup (pyenv/pip/hatch)

The main difference is that this workflow does not have a "lock" file (no `poetry.lock` or `pipenv.lock` file). 
> hatch doesn't currently implement lock files. The lock file mechanism has been non-standard for years and specific to the dependency management system you choose (pip vs. pipenv vs. poetry), but they're now working on a standard, ecosystem-wide solution, and hatch will then implement that.
For now, if you need this for some reason, look at the Dockerfile for how I'm generating a requirements.txt file, which I believe has all the requirements versioned. This is the workaround/stopgap by hatch.
we don't need to lock dependency versions beyond generating iterations of Docker images. Once we know an image passes CI tests, we tag it. That's all.

- Install Python using `Pyenv`.
- Manage virtual environments via `Pyenv` (see caveats) or directly using `venv` (you can link `pyenv` to these virtual environments to use `pyenv` shell commands to activate / deactivate the virtual envs)
- Specify dependencies in `pyproject.toml` file.
- Install the project using `pip`. I.e., `pip install -e .`
- Use `Hatch` to build wheel packages (create build files).
