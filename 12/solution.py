import itertools
from collections import defaultdict

from typing import List, Dict


class Vector:
    def __init__(self, x=0, y=0, z=0):
        self.x = x
        self.y = y
        self.z = z

    def __iter__(self):
        return iter([self.x, self.y, self.z])

    def __abs__(self):
        return Vector3D(*map(abs, self))

    def __add__(self, other):
        return Vector3D(self.x + other.x, self.y + other.y, self.z + other.z)

    def __repr__(self):
        return f'<x={self.x}, y={self.y}, z={self.z}>'

    def __neg__(self):
        return Vector3D(-self.x, -self.y, -self.z)


class Position(Vector):
    pass


class Velocity(Vector):
    pass


class Moon:
    def __init__(self, position: Position, velocity: Velocity):
        self.position = position
        self.velocity = velocity

    def __repr__(self):
        return f'pos={self.position}, vel={self.velocity}'


def calculate_vectors(m1, m2):
    v1 = Vector(
        0 if m1.position.x == m2.position.x else 1 if m2.position.x > m1.position.x else -1,
        0 if m1.position.y == m2.position.y else 1 if m2.position.y > m1.position.y else -1,
        0 if m1.position.z == m2.position.z else 1 if m2.position.z > m1.position.z else -1,
    )
    v2 = -v1
    return v1, v2


def calculate_gravity(moons: List[Moon]) -> Dict[Moon, List[Vector]]:
    vectors: Dict[Moon, List[Vector]] = defaultdict(list)  # tą anotację chciał mypy, ciekawe czy Haskell umie to wywnioskować na podstawie wartości zwracanej.
    for m1, m2 in itertools.combinations(moons, 2):
        v1, v2 = calculate_vectors(m1, m2)
        vectors[m1].append(v1)
        vectors[m2].append(v2)
    return vectors


def apply_gravity(moons: List[Moon]) -> List[Moon]:
    gravity_vectors = calculate_gravity(moons)
    return [Moon(m.position, m.velocity + sum(gravity_vectors[m], Vector()))
            for m in moons]


def apply_velocity(moon: Moon) -> Moon:
    return Moon(moon.position + moon.velocity, moon.velocity)


def step(moons):
    return [apply_velocity(m) for m in apply_gravity(moons)]


def potential_energy(moon):
    return sum(abs(moon.position))


def kinetic_energy(moon):
    return sum(abs(moon.velocity))


def total_energy(moons):
    return sum(potential_energy(m) * kinetic_energy(m) for m in moons)


puzzle = [
        Moon(Position(-4, -14, 8), Velocity()),
        Moon(Position(1, -8, 10), Velocity()),
        Moon(Position(-15, 2, 1), Velocity()),
        Moon(Position(-17, -17, 16), Velocity())
    ]


def main():
    moons = puzzle
    for _ in range(1000):
        moons = step(moons)

    print(total_energy(moons))


if __name__ == '__main__':
    main()
