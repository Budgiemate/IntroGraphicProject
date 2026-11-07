using System;
using UnityEngine;

//this script is put onto the water object
public class WaterSplash : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
            Vector3 worldHitPosition = other.ClosestPoint(transform.position);
            // tell shader where object entered the water
            gameObject.GetComponent<Renderer>().material.SetVector("_WorldHitPosition", worldHitPosition);
            gameObject.GetComponent<Renderer>().material.SetFloat("_Colliding", 1);
    }

    private void OnTriggerExit(Collider other)
    {
        gameObject.GetComponent<Renderer>().material.SetFloat("_Colliding", 0);
    }
}
