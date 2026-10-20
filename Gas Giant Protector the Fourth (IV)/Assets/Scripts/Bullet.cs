using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 15;

    private Vector3 dir = new Vector3(0.0f, -1.0f, 0.0f);
    void Start()
    {

    }

    void Update()
    {
        transform.Translate(dir * speed * Time.deltaTime);

        if (gameObject.transform.position.z > 13)
        {
            Destroy(gameObject);
        }
    }
}
