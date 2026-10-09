using UnityEngine;

public class Enemy : MonoBehaviour
{
    public float speed;

    private Rigidbody enemyRb;
    private GameObject player;
    private bool movingRight = true;

    void Start()
    {
        enemyRb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        if (movingRight)
        {
            enemyRb.linearVelocity = new Vector3(speed, 0, 0);
        }
        else
        {
            enemyRb.linearVelocity = new Vector3(-speed, 0, 0);
        }

        Vector3 pos = enemyRb.position;
        if (pos.x >= 9f && movingRight)
        {
            movingRight = false;
        }
        else if (pos.x <= -9f && !movingRight)
        {
            movingRight = true;
        }
    }
}
