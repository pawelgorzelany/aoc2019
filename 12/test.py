from unittest import TestCase

from solution import Moon, Position, Velocity, step

class Test(TestCase):
    def test_step_function(self):
        moons = [
            Moon(Position(-1, 0, 2), Velocity()),
            Moon(Position(2, -10, -7), Velocity()),
            Moon(Position(4, -8, 8), Velocity()),
            Moon(Position(3, 5, -1), Velocity())
        ]
        m1, m2, m3, m4 = step(moons)

        self.assertEqual(m1.position.x, 2)
        self.assertEqual(m1.position.y, -1)
        self.assertEqual(m1.position.z, 1)
