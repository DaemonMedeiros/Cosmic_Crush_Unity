using UnityEngine;

public class BasicEnemy : MonoBehaviour
{
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
            //Destroy(other.gameObject);
            gameObject.SetActive(false);
            Destroy(gameObject);
        }
    }
}
