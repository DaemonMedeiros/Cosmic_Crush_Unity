using UnityEngine;

public class BasicEnemy : MonoBehaviour
{

    public int Health = 2;
    void Start()
    {
        
    }

    void Update()
    {
        
    }

    void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.CompareTag("Bullet"))
        {
            other.gameObject.SetActive(false);

            if(Health > 1)
            {
                Health--;
            }
            else
            {
                gameObject.SetActive(false);
            }
        }
    }
}
